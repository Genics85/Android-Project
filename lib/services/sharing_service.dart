import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class SharingService {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<String> generateShareLink(String postId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: 'https://gofindme.page.link',
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://www.gofindme.com/post?id=${postId}'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: "com.example.go_find_me",
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      // iosParameters: const IOSParameters(
      //   bundleId: iosBundleId,
      //   minimumVersion: '2',
      // ),
    );

    final ShortDynamicLink uri = await dynamicLinks.buildShortLink(parameters);
    return uri.shortUrl.toString();
  }
}
