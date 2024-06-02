class MessagesModel {
  String title;
  String subTitle;
  String body;

  MessagesModel({
    this.title = "",
    this.subTitle = "",
    this.body = "",
  });

  @override
  String toString() =>
      'MessagesModel(title: "$title", subTitle: "$subTitle", body: "$body")';

  bool get isNotEmpty =>
      title.isNotEmpty || subTitle.isNotEmpty || body.isNotEmpty;
}
