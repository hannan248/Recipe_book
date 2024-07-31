import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/consts/screen_size.dart';
import 'package:recipe_book/provider/auth_provider.dart';
import 'package:recipe_book/provider/catergory_meal_provider.dart';
import 'package:recipe_book/provider/interest_firebase_provider.dart';
import 'package:recipe_book/provider/random_meal.dart';
import 'package:recipe_book/provider/search_provider.dart';
import 'package:recipe_book/provider/selection_provider.dart';
import 'package:recipe_book/screens/detail_page.dart';
import 'package:recipe_book/screens/favorites_screen.dart';
import 'package:recipe_book/screens/login_screen.dart';
import 'package:recipe_book/screens/search_screen.dart';

import '../model/detail_meal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController search = TextEditingController();

  Future<String> _getUserName(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await auth.getUserDetail(user.uid);
    }
    return 'No user signed in';
  }

  Future<List<String>> getInterest(BuildContext context) async {
    final interest = Provider.of<InterestProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    return await interest.getUserInterests(user!.uid);
  }

  late Future<List<Meals>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final interests = await getInterest(context);
      if (interests.isNotEmpty) {
        final mealProvider =
            Provider.of<CategoryMealProvider>(context, listen: false);
        mealProvider.fetchMeals(interests[0]);
      }
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenUtil.getScreenWidth(context);
    double screenWidth = ScreenUtil.getScreenHeight(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                children: [
                  SizedBox(height: screenWidth * 0.04),
                  FutureBuilder<String>(
                    future: _getUserName(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Hello ${snapshot.data}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                                Text(
                                  "What are you cooking today!",
                                  style: TextStyle(
                                      color: Colors.grey.withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                            SizedBox(width: screenWidth*0.03,),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()));
                                final auth = Provider.of<AuthService>(context,
                                    listen: false);
                                auth.signOut();
                              },
                              child:  CircleAvatar(
                                radius: screenWidth*0.03,
                                backgroundColor: Colors.amber,
                                child: const Icon(
                                  Icons.logout,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth*0.01,),
                            GestureDetector(
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>FavoritesScreen()));
                              },
                              child: CircleAvatar(
                                radius: screenWidth*0.03,
                                backgroundColor: Colors.amber,
                                child: const Icon(
                                  Icons.bookmark_border_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                          ],
                        );
                      } else {
                        return const Text('User data not available');
                      }
                    },
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.34,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: search,
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10)),
                          child: IconButton(
                              onPressed: () {
                                final query = search.text.trim();
                                if (query.isNotEmpty) {
                                  Provider.of<SearchProvider>(context,
                                          listen: false)
                                      .updateSearchQuery(query);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchScreen()));
                                  search.clear();
                                }
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              )))
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Categories in which you have interest",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )),
                  SizedBox(height: screenWidth * 0.02),
                  FutureBuilder<List<String>>(
                    future: getInterest(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else if (snapshot.hasData) {
                        return SizedBox(
                          height: screenWidth * 0.08,
                          child: Consumer<SelectionProvider>(
                            builder: (context, selectionProvider, child) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      selectionProvider.selectedIndex == index;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        selectionProvider.selectItem(index);
                                        final mealProvider =
                                            Provider.of<CategoryMealProvider>(
                                                context,
                                                listen: false);
                                        mealProvider
                                            .fetchMeals(snapshot.data![index]);
                                      },
                                      child: Container(
                                        height: screenWidth * 0.08,
                                        width: screenWidth * 0.15,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            snapshot.data![index],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      } else {
                        return const Text('User data not available');
                      }
                    },
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Consumer<CategoryMealProvider>(
                    builder: (context, mealProvider, child) {
                      if (mealProvider.meals.isEmpty) {
                        return const CircularProgressIndicator();
                      } else {
                        return SizedBox(
                          height: screenHeight * 0.85,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mealProvider.meals.length,
                            itemBuilder: (context, index) {
                              final meal = mealProvider.meals[index];
                              final isSelected =
                                  mealProvider.selectedIndex == index;
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02),
                                child: GestureDetector(
                                  onTap: () {
                                    mealProvider.selectItem(index);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                  mealName:
                                                      meal.strMeal.toString(),
                                                )));
                                  },
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.30,
                                        child: Card(
                                          color: isSelected
                                              ? Colors.blue.shade100
                                              : Colors.grey.shade300,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  height: screenWidth * 0.20),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.05),
                                                child: Text(
                                                  meal.strMeal.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenWidth * 0.03),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.02),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Category",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.02,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.02),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    mealProvider
                                                        .currentCategory,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize:
                                                          screenWidth * 0.02,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -screenWidth * 0.00,
                                        right: screenWidth * 0.05,
                                        child: CircleAvatar(
                                          radius: screenWidth * 0.10,
                                          backgroundImage: NetworkImage(
                                              meal.strMealThumb.toString()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: screenWidth * 0.02,
                  ),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Random Meal",
                          style: TextStyle(
                              fontSize: screenWidth * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: IconButton(icon: const Icon(Icons.refresh_outlined),onPressed: (){
                          setState(() {
                            RandomMealProvider().fetchMeals();
                          });
                        },),
                      )
                    ],
                  ),
                  FutureBuilder<List<Meals>>(
                    future: context.read<RandomMealProvider>().fetchMeals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No meals found'));
                      }

                      final meals = snapshot.data!;

                      return SizedBox(
                        height: screenHeight * .35,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: meals.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailPage(
                                              mealName: meals[index]
                                                  .strMeal
                                                  .toString()),),);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Container(
                                    width: screenWidth * 0.40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenWidth * 0.01),
                                          child: CircleAvatar(
                                            radius: screenWidth * 0.08,
                                            backgroundImage: NetworkImage(
                                                meals[index]
                                                    .strMealThumb
                                                    .toString()),
                                          ),
                                        ),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              meals[index].strMeal.toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              meals[index]
                                                  .strCategory
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),)
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      );
                    },
                  ),
                  SizedBox(
                    height: screenHeight * .1,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
