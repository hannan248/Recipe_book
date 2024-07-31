import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/provider/favorites_provider.dart';
import 'package:recipe_book/provider/meal_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final String mealName;

  const DetailPage({super.key, required this.mealName});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealProvider>(context, listen: false).fetchMeals(widget.mealName);
      Provider.of<FavoritesProvider>(context, listen: false).fetchFavorites();
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastLinearToSlowEaseIn,
    );
    setState(() {
      _currentPage = page;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final mealProvider = Provider.of<MealProvider>(context);
    final favoritesProvider=Provider.of<FavoritesProvider>(context);
    if (mealProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final meal = mealProvider.detailMeal?.meals?.first;

    if (meal == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: const Center(child: Text('Meal not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),


      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(meal.strMealThumb ?? ""),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Row(
                      children: [
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: Text(
                              meal.strCategory.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        CircleAvatar(
                          child: IconButton(
                            onPressed: () {
                              launchUrl(
                                Uri.parse(meal.strYoutube.toString()),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            icon: Icon(
                              Icons.videocam_outlined,
                              size: screenWidth * 0.06,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.50),
                        CircleAvatar(
                          child: IconButton(
                            onPressed: () {
                              if (favoritesProvider.isFavorite(meal.strMeal!)) {
                                favoritesProvider.removeFavorite(meal.strMeal!);
                              } else {
                                favoritesProvider.addFavorite(meal.strMeal!);
                              }
                            },
                            icon: Icon(
                              favoritesProvider.isFavorite(meal.strMeal!)
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                overflow: TextOverflow.ellipsis,
                meal.strMeal ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.06,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.45,
                    decoration: BoxDecoration(
                      color: _currentPage == 0
                          ? Colors.black
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        _goToPage(0);
                      },
                      child: Text(
                        "Ingredients",
                        style: TextStyle(
                          color: _currentPage == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    width: screenWidth * 0.45,
                    decoration: BoxDecoration(
                      color: _currentPage == 1
                          ? Colors.black
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        _goToPage(1);
                      },
                      child: Text(
                        "Procedure",
                        style: TextStyle(
                          color: _currentPage == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenWidth * 0.03,
              ),
              SizedBox(
                height: screenHeight * 0.4,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    ListView.builder(
                      itemBuilder: (context, index) {
                        final ingredient = meal.ingredients[index];
                        final measure = meal.measures[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: screenWidth * 0.9,
                            height: screenHeight * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: ListTile(
                                leading: Image.network(
                                  "https://www.themealdb.com/images/ingredients/$ingredient.png",
                                  height: screenWidth * 0.30,
                                  width: screenWidth * 0.20,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: screenWidth * 0.20,
                                      width: screenWidth * 0.20,
                                    );
                                  },
                                ),
                                title: Text(
                                  ingredient ?? 'No Ingredient',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  measure ?? 'No Measure',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.04),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: meal.ingredients.length ?? 0,
                    ),
                    SingleChildScrollView(
                      child: Card(
                        elevation: 20,
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Text(
                            meal.strInstructions ?? 'No Instructions Available',
                            style: TextStyle(fontSize: screenWidth * 0.06),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
