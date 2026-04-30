import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/network/api_client.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService{
    final GoRouter _route;
    final FirebaseMessaging _fcm=FirebaseMessaging.instance;
    final FlutterLocalNotificationsPlugin _localNotifications= FlutterLocalNotificationsPlugin();

    static const _channelId ='rythmify_notifications';
    static const _channelName='Rythmify Notifications';

    PushNotificationService(this._route);

    Future<void> initialize()async{
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        
        await _requestPermission();
        await _initLocalNotifications();
        await _registerToken();
        _listenForTokenRefresh();
        _handleForegroundmessages();
        _handleMessageOpenApp();
        await _handleIntitialMessage();
    }

    Future<void> _requestPermission() async{
        await _fcm.requestPermission(alert: true, badge: true,sound: true);
    }

    Future<void> _initLocalNotifications()async{
        const androidInit = AndroidInitializationSettings('@drawable/logo');

        await _localNotifications.initialize(
            settings: const InitializationSettings(android: androidInit),
            onDidReceiveNotificationResponse: (details)=> _navigateFromPayload(details.payload)
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation
            <AndroidFlutterLocalNotificationsPlugin>
            ()?.createNotificationChannel(
                const AndroidNotificationChannel(
                    _channelId,
                    _channelName,
                    importance: Importance.high
                )
            );

        
    }


    Future<void> _registerToken()async{
        final token=await _fcm.getToken();
        if(token!=null) _postToken(token);
    }

    Future<void> _postToken(String token)async{
        try{
            await apiClient.dio.post(
                '/notifications/push/register', 
                data: {'token': token, 'platform': 'android'}, 
            );
        }catch(_){}
    }

    Future<void> unregisterToken()async{
        try{
            final token=await _fcm.getToken();
            if(token==null) return;
            await apiClient.dio.post(
                '/notifications/push/unregister',
                data: {'token': token}
            );
            await _fcm.deleteToken();
        }catch(_){}
    }

    void _handleForegroundmessages(){
        FirebaseMessaging.onMessage.listen((message){
            final notification=message.notification;
            if(notification==null) return;

            _localNotifications.show(
                id: notification.hashCode,
                title: notification.title,
                body: notification.body,
                notificationDetails: NotificationDetails(
                    android: AndroidNotificationDetails(
                        _channelId,
                        _channelName,
                        importance:Importance.high,
                        priority:Priority.high,
                        icon:'@drawable/logo',
                    )
                 ),
                payload: _payloadFromData(message.data)
            );
        });
    }

    void _handleMessageOpenApp(){
        FirebaseMessaging.onMessageOpenedApp.listen(
            (message)=>_navigateFromData(message.data)
        );
    }

    Future<void> _handleIntitialMessage()async{
        final message=await _fcm.getInitialMessage();
        if(message!=null) _navigateFromData(message.data);
    }

    String? _payloadFromData(Map<String,dynamic> data){
        final type=data['type'] as String?;
        if(type==null) return null;
        final resourceType =data['resource_type'] as String? ??'';
        final resourceId =data['resource_id'] as String? ??'';
        return '$type:$resourceType:$resourceId';
    }

    void _navigateFromPayload(String? payload){
        if(payload==null) return;
        final parts=payload.split(':');
        _navigateByType(
            type: parts.isNotEmpty?parts[0]:null,
            resourceId: parts.length>2?parts[2]:null,
            resourceType: parts.length>1?parts[1]:null
        );
    }

    void _navigateFromData(Map<String,dynamic> data){
        _navigateByType(
            type: data['type'] as String?,
            resourceId: data['resource_id'] as String?,
            resourceType: data['resource_type'] as String?,
        );
    }

    void _listenForTokenRefresh() {
        _fcm.onTokenRefresh.listen((token) => _postToken(token));
    }

    void _navigateByType({
        required String? type,
        String? resourceType,
        String? resourceId,
    }){
        final hasResource = resourceId != null && resourceId.isNotEmpty;

        switch (type) {
            case 'follow':
                _route.push('/home/notifications');
            case 'like' || 'repost' || 'comment':
                if (hasResource && resourceType == 'playlist') {
                    _route.push('/home/playlist/$resourceId');
                } else {
                    _route.push('/home/notifications');
                }
            case 'new_post_by_followed':
                _route.push('/home/notifications');
            case 'message':
                if (hasResource) {
                    _route.push('/home/inbox/chat/$resourceId');
                } else {
                    _route.push('/home/inbox');
                }
            default:
                _route.push('/home/notifications');
        }
    }
}