import 'package:appwrite/appwrite.dart';

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('64f382383b3dcdf1a9f7')
    .setSelfSigned(
        status: true); // For self signed certificates, only use for development

final Account account = Account(client);
// final  Users users = Users(client);
final String uniqueId = ID.unique();
final Databases database = Databases(client);
final Avatars avatars = Avatars(client);
final Storage storage = Storage(client);
// Subscribe to files channel
final Realtime realtime = Realtime(client);
