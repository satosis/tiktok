class CommentsModel {
  final String status;
  final data;

  CommentsModel( {this.status,this.data} );

  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    return CommentsModel(
      status:json["status"],
      data:json["data"],
    );
  }

  // static List<Data> parseData(json) {
  //   List list = json;
  //   List<Data> listData = list.map((data) => Data.fromJson(data)).toList();
  //   return listData;
  // }
}

class Data {
  final int commentId;
  final String name;
  final String pic;
  final String comment;

  Data( {this.commentId,this.name,this.pic,this.comment,} );

  factory Data.fromJson(Map<String, dynamic> json) {
     return Data(
       commentId: json["comment_id"],
       name: json["name"],
       pic: json["pic"],
       comment: json["comment"],
     );
  }
}