import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/model/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(AuthInitial());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final auth = await _repository.login(
        email: email,
        password: password,
      );
      if (!isClosed) emit(AuthSuccess(auth));
    } catch (error) {
      if (!isClosed) emit(AuthFailure(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _repository.close();
    return super.close();
  }
}
