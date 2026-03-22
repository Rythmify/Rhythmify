import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/usecases/block_user_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

class BlockUserNotifier extends StateNotifier<bool>{
    final Ref ref;
    BlockUserNotifier({
        required this.ref
    }):super(false);

    Future<void> blockUser({
        required String participantId
    })async{
      state=true;
      final uCase=BlockUserUsecase(repo:ref.read(repositoryprovider));
      await(uCase(participantId));
      state=false;
    }
}