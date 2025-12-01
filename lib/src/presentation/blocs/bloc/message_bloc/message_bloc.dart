import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'package:webchat/src/domain/repo/message_repo.dart';
import 'package:webchat/src/domain/usecase/message_usecase/store_message_usecase.dart';
import 'package:webchat/src/presentation/model/chat_message.dart';
part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepo _messageRepo;
  final StoreMessageUsecase _storeMessageUsecase;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  int? _currentUserId;


  MessageBloc({
    required MessageRepo messageRepo,
    required StoreMessageUsecase storeMessageUsecase,
  })  : _messageRepo = messageRepo,
        _storeMessageUsecase = storeMessageUsecase,
        super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<UpdateMessageStatus>(_onUpdateMessageStatus);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<_MessagesError>(_onMessagesError);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    if (_currentUserId != event.userId) {
      await _messagesSubscription?.cancel();
      _currentUserId = event.userId;
    }

    emit(MessageLoading());
    
    try {
      final initialMessages = await _messageRepo.getMessagesByUserId(event.userId);
      final chatMessages = initialMessages.map((m) => _entityToChatMessage(m)).toList();
      emit(MessageLoaded(messages: chatMessages, userId: event.userId));

      _messagesSubscription = _messageRepo.watchMessagesByUserId(event.userId).listen(
        (messages) {
          add(_MessagesUpdated(messages: messages, userId: event.userId));
        },
        onError: (error) {
          add(_MessagesError(message: error.toString()));
        },
      );
    } catch (e) {
      emit(MessageError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessageState> emit) async {
    if (event.message.trim().isEmpty) return;
    final now = DateTime.now();
    final senderMessage = MessageEntity(
      userId: event.userId,
      message: event.message,
      date: now,
      isCurrentUser: true,
      status: MessageStatus.sending, 
    );

    await _storeMessageUsecase.call(senderMessage);
    
    final messages = await _messageRepo.getMessagesByUserId(event.userId);
    messages.lastWhere(
      (m) => m.isCurrentUser && 
             m.message == event.message &&
             m.status == MessageStatus.sending,
      orElse: () => messages.where((m) => m.isCurrentUser).last,
    );
    


  }

  Future<void> _onMessageReceived(MessageReceived event, Emitter<MessageState> emit) async {
    final now = DateTime.now();
    
    final currentState = state;
    if (currentState is MessageLoaded) {
      final receiverExists = currentState.messages.any((m) => 
        !m.isCurrentUser && 
        m.message == event.message &&
        now.difference(DateTime.parse(m.timestamp)).inSeconds < 10
      );
      
      if (receiverExists) {
        return;
      }
    }
    
    final messageEntity = MessageEntity(
      userId: event.userId,
      message: event.message,
      date: now,
      isCurrentUser: false,
      status: MessageStatus.read,
    );

    await _storeMessageUsecase.call(messageEntity);
  }

  Future<void> _onUpdateMessageStatus(UpdateMessageStatus event, Emitter<MessageState> emit) async {
    try {
      await _messageRepo.updateMessageStatus(event.messageId, event.status);
    } catch (e) {
      throw Exception('Error updating message status: $e');
    }
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<MessageState> emit) {
    final chatMessages = event.messages.map((m) => _entityToChatMessage(m)).toList();
    emit(MessageLoaded(messages: chatMessages, userId: event.userId));
  }

  void _onMessagesError(_MessagesError event, Emitter<MessageState> emit) {
    emit(MessageError(message: event.message));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  ChatMessage _entityToChatMessage(MessageEntity entity) {
    return ChatMessage(
      id: entity.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: entity.message,
      timestamp: entity.date.toIso8601String(),
      isCurrentUser: entity.isCurrentUser,
      status: entity.status,
    );
  }
}
