import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RecipeInfoApp(),
    );
  }
}

class RecipeInfoApp extends StatefulWidget {
  @override
  _RecipeInfoAppState createState() => _RecipeInfoAppState();
}

class _RecipeInfoAppState extends State<RecipeInfoApp> {
  List<String> cuisines = [
    'American',
    'British',
    'Canadian',
    'Chinese',
    'Dutch',
    'Egyptian',
    'French',
    'Greek',
    'Indian',
    'Italian',
    'Japanese',
    'Mexican',
    'Moroccan',
    'Spanish',
    'Thai',
    'Vietnamese'
  ];

  String? selectedCuisine;
  List<dynamic>? _recipeData;
  bool _isLoading = false;

  Future<void> fetchRecipeInfo(String cuisine) async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://www.themealdb.com/api/json/v1/1/filter.php?a=$cuisine';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _recipeData = json.decode(response.body)['meals'];
        _isLoading = false;
      });
    } else {
      // Tratar erro
      setState(() {
        _recipeData = null;
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(String mealId) async {
    final url = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['meals'][0];
      return data;
    } else {
      throw Exception('Falha ao buscar detalhes da receita');
    }
  }

  void showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) async {
    final mealId = recipe['idMeal'];
    final recipeDetails = await fetchRecipeDetails(mealId);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetailsPage(recipe: recipeDetails)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livro de Receitas'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                hint: Text('Selecione uma cozinha'),
                value: selectedCuisine,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCuisine = newValue;
                  });
                },
                items: cuisines.map((String cuisine) {
                  return DropdownMenuItem<String>(
                    value: cuisine,
                    child: Text(cuisine),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedCuisine != null) {
                    fetchRecipeInfo(selectedCuisine!);
                  }
                },
                child: Text('Buscar'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : _recipeData != null
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _recipeData!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  showRecipeDetails(context, _recipeData![index]);
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Text(_recipeData![index]['strMeal']),
                                    leading: Image.network(
                                      _recipeData![index]['strMealThumb'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Text('Nenhuma receita encontrada.'),
            ],
          ),
        ),
      ),
    );
  }
}