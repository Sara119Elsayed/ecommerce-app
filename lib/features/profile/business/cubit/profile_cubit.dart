import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/model/profile_model.dart';
import '../../data/repository/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileInitial());

  final ProfileRepository _repository;

  Future<void> loadProfile(int userId) async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile(userId);
      if (!isClosed) emit(ProfileLoaded(profile));
    } catch (error) {
      if (!isClosed) emit(ProfileFailure(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _repository.close();
    return super.close();
  }
}
