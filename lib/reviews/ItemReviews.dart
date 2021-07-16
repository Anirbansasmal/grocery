import '../reviews/ReviewModel.dart';
import 'package:flutter/material.dart';

class ItemReview extends StatefulWidget {
  final ReviewsModel itemReview;

  const ItemReview({Key key, this.itemReview}) : super(key: key);

  @override
  _ItemReviewState createState() => _ItemReviewState();
}

class _ItemReviewState extends State<ItemReview> {
  ReviewsModel item;

  int rowId;

  @override
  void initState() {
    item = widget.itemReview;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
                // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.firstname + " " + item.lastname,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0XFF0D0D0D),
                          ),
                          softWrap: true,
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          item.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0XFF0D0D0D),
                          ),
                          softWrap: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${item.reviewDateStr}",
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
