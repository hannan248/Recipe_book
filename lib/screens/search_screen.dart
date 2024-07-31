import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/consts/screen_size.dart';
import 'package:recipe_book/model/detail_meal.dart';
import 'package:recipe_book/provider/search_provider.dart';
import 'package:recipe_book/screens/detail_page.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtil.getScreenWidth(context);
    double screenHeight = ScreenUtil.getScreenHeight(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return FutureBuilder<List<Meals>>(
            future: searchProvider.futureResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No results found'));
              } else {
                final results = snapshot.data!;
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final meal = results[index];
                    return InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(mealName: meal.strMeal.toString())));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: Container(
                          width: screenWidth * 0.90,
                          height: screenHeight * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      meal.strMealThumb.toString(),
                                      height: screenWidth * 0.20,
                                      width: screenWidth * 0.20,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          meal.strMeal.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.05,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          meal.strCategory.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
