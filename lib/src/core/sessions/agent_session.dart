import 'dart:async';
import 'package:flutter_ai_agent_sdk/src/llm/providers/llm_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_ai_agent_sdk/src/core/agents/agent_config.dart';
import 'package:flutter_ai_agent_sdk/src/core/events/agent_events.dart';
import 'package:flutter_ai_agent_sdk/src/core/models/message.dart';
import 'package:flutter_ai_agent_sdk/src/core/sessions/session_state.dart';
import 'package:flutter_ai_agent_sdk/src/memory/conversation_memory.dart';
import 'package:flutter_ai_agent_sdk/src/tools/tool_executor.dart';
import 'package:flutter_ai_agent_sdk/src/utils/logger.dart';

class AgentSession {
  
  AgentSession({
    String? id,
    required this.config,
    ConversationMemory? memory,
    ToolExecutor? toolExecutor,
  })  : id = id ?? const Uuid().v4(),
        memory = memory ?? ConversationMemory(maxMessages: config.maxHistoryMessages),
        toolExecutor = toolExecutor ?? ToolExecutor(tools: config.tools);
  final String id;
  final AgentConfig config;
  final ConversationMemory memory;
  final ToolExecutor toolExecutor;
  
  final BehaviorSubject<AgentEvent> _eventController = BehaviorSubject<AgentEvent>();
  final BehaviorSubject<SessionStatus> _stateController = BehaviorSubject<SessionStatus>.seeded(
    const SessionStatus(state: SessionState.idle),
  );
  final BehaviorSubject<List<Message>> _messagesController = BehaviorSubject<List<Message>>.seeded(<Message>[]);
  
  Stream<AgentEvent> get events => _eventController.stream;
  Stream<SessionStatus> get state => _stateController.stream;
  Stream<List<Message>> get messages => _messagesController.stream;
  
  SessionStatus get currentState => _stateController.value;
  List<Message> get currentMessages => _messagesController.value;
  
  bool _isActive = false;
  StreamSubscription? _sttSubscription;
  
  Future<void> start() async {
    if (_isActive) return;
    
    try {
      _isActive = true;
      _updateState(SessionState.idle);
      _emitEvent(AgentStartedEvent());
      
      // Initialize STT if available
      if (config.sttService != null) {
        await config.sttService!.initialize();
      }
      
      // Initialize TTS if available
      if (config.ttsService != null) {
        await config.ttsService!.initialize();
      }
      
      AgentLogger.info('Session started: $id');
    } catch (e, stack) {
      _handleError('Failed to start session', e, stack);
    }
  }
  
  Future<void> stop() async {
    if (!_isActive) return;
    
    try {
      _isActive = false;
      await _sttSubscription?.cancel();
      await config.sttService?.dispose();
      await config.ttsService?.dispose();
      
      _updateState(SessionState.idle);
      _emitEvent(AgentStoppedEvent());
      
      AgentLogger.info('Session stopped: $id');
    } catch (e, stack) {
      _handleError('Failed to stop session', e, stack);
    }
  }
  
  Future<void> sendMessage(final String text) async {
    if (!_isActive) {
      throw StateError('Session is not active');
    }
    
    try {
      _updateState(SessionState.processing);
      
      // Create user message
      final Message userMessage = Message(
        id: const Uuid().v4(),
        role: MessageRole.user,
        type: MessageType.text,
        content: text,
      );
      
      _addMessage(userMessage);
      _emitEvent(MessageSentEvent(userMessage));
      
      // Get LLM response
      final Message response = await _getLLMResponse();
      
      // Handle tool calls if any
      if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
        await _executeToolCalls(response.toolCalls!);
      }
      
      // Add assistant message
      _addMessage(response);
      _emitEvent(MessageReceivedEvent(response));
      
      // Speak response if TTS enabled
      if (config.ttsService != null && response.content.isNotEmpty) {
        await _speakResponse(response.content);
      }
      
      _updateState(SessionState.idle);
    } catch (e, stack) {
      _handleError('Failed to send message', e, stack);
    }
  }
  
  Future<void> startListening() async {
    if (config.sttService == null) {
      throw StateError('STT service not configured');
    }
    
    try {
      _updateState(SessionState.listening);
      _emitEvent(UserSpeechStartedEvent());
      
      final String transcript = await config.sttService!.startListening();
      
      if (transcript.isNotEmpty) {
        _emitEvent(UserSpeechEndedEvent(transcript));
        await sendMessage(transcript);
      }
    } catch (e, stack) {
      _handleError('Failed to listen', e, stack);
    }
  }
  
  Future<void> stopListening() async {
    await config.sttService?.stopListening();
  }
  
  Future<Message> _getLLMResponse() async {
    final List<Message> context = memory.getContext();
    final Stream<LLMResponse> stream = config.llmProvider.generateStream(
      messages: context,
      tools: config.tools.isNotEmpty ? config.tools : null,
    );
    
    final StringBuffer buffer = StringBuffer();
    List<ToolCall>? toolCalls;
    
    await for (final LLMResponse chunk in stream) {
      if (chunk.content != null) {
        buffer.write(chunk.content);
        _emitEvent(StreamingTextEvent(chunk.content!));
      }
      
      if (chunk.toolCalls != null) {
        toolCalls = chunk.toolCalls;
      }
    }
    
    _emitEvent(StreamingTextEvent('', isComplete: true));
    
    return Message(
      id: const Uuid().v4(),
      role: MessageRole.assistant,
      type: MessageType.text,
      content: buffer.toString(),
      toolCalls: toolCalls,
    );
  }
  
  Future<void> _executeToolCalls(final List<ToolCall> toolCalls) async {
    for (final ToolCall toolCall in toolCalls) {
      try {
        _emitEvent(ToolCallStartedEvent(toolCall.name, toolCall.arguments));
        
        final result = await toolExecutor.execute(
          toolCall.name,
          toolCall.arguments,
        );
        
        _emitEvent(ToolCallCompletedEvent(toolCall.name, result));
        
        // Add tool result to memory
        final Message toolMessage = Message(
          id: const Uuid().v4(),
          role: MessageRole.tool,
          type: MessageType.toolResult,
          content: result.toString(),
          metadata: <String, dynamic>{'tool_call_id': toolCall.id},
        );
        
        _addMessage(toolMessage);
      } catch (e, stack) {
        AgentLogger.error('Tool execution failed: ${toolCall.name}', e, stack);
      }
    }
  }
  
  Future<void> _speakResponse(final String text) async {
    if (config.ttsService == null) return;
    
    try {
      _updateState(SessionState.speaking);
      _emitEvent(AgentSpeechStartedEvent());
      
      await config.ttsService!.speak(text);
      
      _emitEvent(AgentSpeechEndedEvent());
      _updateState(SessionState.idle);
    } catch (e, stack) {
      AgentLogger.error('TTS failed', e, stack);
    }
  }
  
  void _addMessage(final Message message) {
    memory.addMessage(message);
    _messagesController.add(memory.getMessages());
  }
  
  void _updateState(final SessionState state, {final String? error}) {
    _stateController.add(SessionStatus(
      state: state,
      errorMessage: error,
    ),);
  }
  
  void _emitEvent(final AgentEvent event) {
    _eventController.add(event);
  }
  
  void _handleError(final String message, final Object error, final StackTrace stack) {
    AgentLogger.error(message, error, stack);
    _updateState(SessionState.error, error: error.toString());
    _emitEvent(ErrorEvent(error.toString(), stack));
  }
  
  void dispose() {
    _eventController.close();
    _stateController.close();
    _messagesController.close();
  }
}
