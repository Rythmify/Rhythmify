import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_followings_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

final getFollowingsProvider=FutureProvider((ref)async{
  final uCase=GetFollowingsUsecase(repo: ref.read(repositoryprovider));
  final myId=ref.watch(currentUserIdProvider);
  final followings=await uCase(myId);
  return followings;
});