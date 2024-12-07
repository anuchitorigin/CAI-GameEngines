import 'package:universal_html/html.dart' as html;

class DomainService {
  static final hostURL = '${html.window.location.protocol}//${html.window.location.hostname}';
  static final mainEndpoint = '$hostURL:57100';
  static final authEndpoint = '$hostURL:57101';
  static final dataEndpoint = '$hostURL:57102';
}