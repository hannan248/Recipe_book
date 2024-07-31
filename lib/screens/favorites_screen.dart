import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/consts/screen_size.dart';
import 'package:recipe_book/provider/favorites_provider.dart';
import 'package:recipe_book/screens/detail_page.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenUtil.getScreenWidth(context);
    double screenHeight = ScreenUtil.getScreenHeight(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          'Favorite Items',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favoritesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoritesProvider.favorites.isEmpty
          ? const Center(child: Text('No favorites added.'))
          : ListView.builder(
        itemCount: favoritesProvider.favorites.length,
        itemBuilder: (context, index) {
          final item = favoritesProvider.favorites[index];

          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(mealName: item)));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
              child: Dismissible(
                key: ValueKey(item),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  favoritesProvider.removeFavorite(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$item removed'),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                child: Container(
                  height: screenHeight * 0.10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            favoritesProvider.removeFavorite(item);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
