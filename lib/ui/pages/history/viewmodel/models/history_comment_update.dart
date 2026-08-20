class HistoryCommentUpdate {
  final int historyEntryId;
  final String? comments;

  const HistoryCommentUpdate({
    required this.historyEntryId,
    this.comments,
  });
}
