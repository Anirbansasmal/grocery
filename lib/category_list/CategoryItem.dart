import 'package:flutter/material.dart';

import '../category_list/CategoryModel.dart';
import '../products/ProductListScreen.dart';

class CategoryItem extends StatefulWidget {
  final CategoryData categoryData;

  const CategoryItem({Key key, this.categoryData}) : super(key: key);
  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    double containerWidth = 100;
    CategoryData categoryData = widget.categoryData;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(
              categoryID: categoryData.catId,
              categoryName: categoryData.name,
              searchKeyword: "",
              // isAgent:isAgent,
            ),
          ),
        );
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9.0),
            child: Image.network(
              categoryData.categoryimgstat,
              height: containerWidth,
              width: containerWidth,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace stackTrace) {
                return Container();
              },
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: containerWidth,
                  width: containerWidth,
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.grey,
                        ),
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: 120,
              child: Text(
                categoryData.name,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,

                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
