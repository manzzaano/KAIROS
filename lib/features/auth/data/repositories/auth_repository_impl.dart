import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, User>> login(LoginParams params) async {
    try {
      final user = await _remoteDataSource.login(params.email, params.password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // TODO Sprint 2: implement logout
    return const Right(null);
  }
}
