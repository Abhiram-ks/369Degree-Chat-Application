import 'package:get_it/get_it.dart';

import '../../api/api_service.dart';
import '../../api/socket/websocket_service.dart';
import '../../src/data/datasource/local/database_helper.dart';
import '../../src/data/datasource/local/store_user_local_datasource.dart';
import '../../src/data/datasource/local/message_local_datasource.dart';
import '../../src/data/datasource/remote/get_store_users_remote_datasource.dart';
import '../../src/data/repo/get_store_user_repo_impl.dart';
import '../../src/data/repo/get_single_user_repo_impl.dart';
import '../../src/data/repo/message_repo_impl.dart';
import '../../src/data/repo/websocket_repo_impl.dart';
import '../../src/domain/repo/get_user_repo.dart';
import '../../src/domain/repo/get_single_user_repo.dart';
import '../../src/domain/repo/message_repo.dart';
import '../../src/domain/repo/websocket_repo.dart';
import '../../src/domain/usecase/user_usecase/get_usercase.dart';
import '../../src/domain/usecase/get_single_user_usecase.dart';
import '../../src/domain/usecase/message_usecase/get_messages_usecase.dart';
import '../../src/domain/usecase/message_usecase/store_message_usecase.dart';
import '../../src/presentation/blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';
import '../../src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import '../../src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import '../../src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import '../../src/presentation/blocs/cubit/select_user_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register DatabaseHelper
  sl.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper.instance,
  );

  // Register ApiService
  sl.registerLazySingleton<ApiService>(
    () => ApiService(),
  );

  // Register WebSocketService
  sl.registerLazySingleton<WebSocketService>(
    () => WebSocketService(),
  );

  //! Register DataSources
  sl.registerLazySingleton<StoreUserLocalDataSource>(
    () => StoreUserLocalDataSource(
      dbHelper: sl<DatabaseHelper>(),
    ),
  );

  sl.registerLazySingleton<MessageLocalDataSource>(
    () => MessageLocalDataSource(
      dbHelper: sl<DatabaseHelper>(),
    ),
  );

  sl.registerLazySingleton<GetUsersRemoteDataSource>(
    () => GetUsersRemoteDataSource(
      apiService: sl<ApiService>(),
    ),
  );

  //! Register Repositories
  // Users list repository (remote + local)
  sl.registerLazySingleton<GetStoreUserRepo>(
    () => GetStoreUserRepoImpl(
      getUsersRemoteDataSource: sl<GetUsersRemoteDataSource>(),
      storeUserLocalDataSource: sl<StoreUserLocalDataSource>(),
    ),
  );

  // Single user repository (local)
  sl.registerLazySingleton<GetSingleUserRepo>(
    () => GetSingleUserRepoImpl(
      storeUserLocalDataSource: sl<StoreUserLocalDataSource>(),
    ),
  );

  // Message repository (local)
  sl.registerLazySingleton<MessageRepo>(
    () => MessageRepoImpl(
      localDataSource: sl<MessageLocalDataSource>(),
    ),
  );

  // WebSocket repository
  sl.registerLazySingleton<WebSocketRepo>(
    () => WebSocketRepoImpl(
      webSocketService: sl<WebSocketService>(),
    ),
  );

  //! Register UseCases
  sl.registerLazySingleton<GetUserUsecase>(
    () => GetUserUsecase(
      getStoreUserRepo: sl<GetStoreUserRepo>(),
    ),
  );

  sl.registerLazySingleton<GetSingleUserUsecase>(
    () => GetSingleUserUsecase(
      getSingleUserRepo: sl<GetSingleUserRepo>(),
    ),
  );

  sl.registerLazySingleton<GetMessagesUsecase>(
    () => GetMessagesUsecase(
      messageRepo: sl<MessageRepo>(),
    ),
  );

  sl.registerLazySingleton<StoreMessageUsecase>(
    () => StoreMessageUsecase(
      messageRepo: sl<MessageRepo>(),
    ),
  );

  //! Register Blocs
  sl.registerFactory<GetStoreUserBloc>(
    () => GetStoreUserBloc(
      getUserUsecase: sl<GetUserUsecase>(),
      localDataSource: sl<StoreUserLocalDataSource>(),
    ),
  );

  sl.registerFactory<GetSingleUserBloc>(
    () => GetSingleUserBloc(
      getSingleUserUsecase: sl<GetSingleUserUsecase>(),
    ),
  );

  //! Register WebSocket and Message Blocs
  sl.registerFactory<WebSocketBloc>(
    () => WebSocketBloc(
      webSocketService: sl<WebSocketService>(),
    ),
  );

  sl.registerFactory<MessageBloc>(
    () => MessageBloc(
      messageRepo: sl<MessageRepo>(),
      storeMessageUsecase: sl<StoreMessageUsecase>(),
    ),
  );

  //! Register Cubits
  sl.registerFactory<SelectUserCubit>(
    () => SelectUserCubit(),
  );
}