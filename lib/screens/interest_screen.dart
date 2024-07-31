import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/consts/screen_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_book/provider/catergory_provider.dart';
import 'package:recipe_book/provider/interest_firebase_provider.dart';
import 'package:recipe_book/screens/home_screen.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  _InterestScreenState createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  bool isLoading=false;
  final List<bool> _selectedCategories = List<bool>.filled(18, false);
  int _selectedCount = 0;
  String? get _userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void _onCategorySelected(int index) {
    if (_selectedCategories[index]) {
      setState(() {
        _selectedCount--;
        _selectedCategories[index] = false;
      });
    } else {
      if (_selectedCount >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only choose up to 5 categories.'),
          ),
        );
      } else {
        setState(() {
          _selectedCount++;
          _selectedCategories[index] = true;
        });
      }
    }
  }

  void _saveInterests() async {
    setState(() {
      isLoading =true;
    });
    final userId = _userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in.'),
        ),
      );
      return;
    }

    final selectedInterests = _selectedCategories
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) =>
            Provider.of<CategoryProvider>(context, listen: false)
                .categories?[entry.key]
                .strCategory ??
            '')
        .toList();

    try {
      await Provider.of<InterestProvider>(context, listen: false)
          .saveUserInterests(userId, selectedInterests).then((_){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interests saved successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save interests.'),
        ),
      );
      print(e);
    } finally{
     setState(() {
       isLoading=false;
     });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = ScreenUtil.getScreenHeight(context);
    double screenWidth = ScreenUtil.getScreenWidth(context);

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider!.errorMessage.isNotEmpty) {
          return Scaffold(
            body: Center(child: Text('Error: ${provider.errorMessage}')),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    const Text(
                      "Choose Categories that represent your Interest",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select  3 to 5 Categories",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        if (_selectedCount >= 3)
                         isLoading?const Center(
                           child: CircularProgressIndicator(),
                         ): ElevatedButton(
                           onPressed: _saveInterests,
                           child: const Text('Done'),
                         ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemCount: provider.categories?.length ?? 0,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          final category = provider.categories?[index];
                          return GestureDetector(
                            onTap: () => _onCategorySelected(index),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * .02),
                              child: Container(
                                width: screenWidth * 0.35,
                                height: screenHeight * 0.20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedCategories[index]
                                        ? Colors.blue
                                        : Colors.black,
                                    width: _selectedCategories[index] ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: screenWidth * 0.12,
                                      backgroundImage: NetworkImage(
                                          category?.strCategoryThumb ?? ''),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Text(
                                      category?.strCategory ?? 'Unknown',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
