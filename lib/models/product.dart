class Product {                                // Définition de la classe Product, représente un produit unique
  final int id;                                // Identifiant unique du produit
  final String title;                          // Titre ou nom du produit
  final double price;                          // Prix du produit (double pour gérer les décimales)
  final String description;                    // Description du produit
  final String category;                       // Catégorie (ex: "electronics", "clothes")
  final String image;                          // URL de l’image du produit
  final Rating rating;                         // Note (rating) du produit, objet de type Rating

  Product({                                     // Constructeur de la classe Product
    required this.id,                          // Les champs sont obligatoires (required)
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // Factory constructor pour créer un Product à partir d’un JSON (Map clé/valeur)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,                   // Récupère l’id (converti en int)
      title: json['title'] as String,          // Récupère le titre (String)
      price: (json['price'] as num).toDouble(),// Récupère le prix (num → double pour être sûr)
      description: json['description'] as String, // Récupère la description
      category: json['category'] as String,    // Récupère la catégorie
      image: json['image'] as String,          // Récupère l’URL de l’image
      rating: Rating.fromJson(json['rating']), // Récupère l’objet rating via son fromJson
    );
  }

  // Getter calculé : retourne le prix formaté avec 2 décimales + symbole €
  String get formattedPrice => '${price.toStringAsFixed(2)} €';

  // Getter calculé : retourne une chaîne d’étoiles + la note et le nombre de votes
  String get starsDisplay => '⭐ ${rating.rate.toStringAsFixed(1)} (${rating.count})';
}

// Classe Rating, utilisée dans Product pour représenter la note du produit
class Rating {
  final double rate;                           // Note moyenne (ex: 4.5)
  final int count;                             // Nombre de votes

  Rating({required this.rate, required this.count}); // Constructeur Rating avec paramètres obligatoires

  // Factory constructor pour créer un Rating à partir d’un JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),  // Convertit le champ "rate" en double
      count: json['count'] as int,             // Convertit le champ "count" en int
    );
  }
}