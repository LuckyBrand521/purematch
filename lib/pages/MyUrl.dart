class MyUrl {
  static String url(String endPoint) {
    if (endPoint.substring(0, 1) == "/") endPoint = endPoint.substring(1);
//    return "http://100.64.14.157:8081/$endPoint";
    return "http://pm-match.us-west-2.elasticbeanstalk.com/$endPoint";
  }

  static String chatImageUrl(String endPoint) {
    if (endPoint == null) return null;
    if (endPoint.substring(0, 3) == "http") return endPoint;
    if (endPoint.substring(0, 1) == "/") endPoint = endPoint.substring(1);
    return "https://pure-match-prod.s3.amazonaws.com/ChatUploads/$endPoint";
  }
}
