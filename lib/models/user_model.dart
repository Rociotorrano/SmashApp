class UserModel {
  final String id;
  final String email;
  final String name;
  final String gender;
  final String age; // 'edad_rango'
  final int yearsPlaying; // 'experiencia_padel'
  final String category;
  final String position; // 'posicion_preferida'
  final String schedule; // 'horario_disponible'
  final String locality;
  final String? biography;
  final String? profileImageUrl; // 'foto_principal_url' or 'foto'

  // Extra fields for full profile if needed
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.gender = '',
    this.age = '',
    this.yearsPlaying = 0,
    this.category = '',
    this.position = '',
    this.schedule = '',
    this.locality = '',
    this.biography,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        // We use this mostly for creating/updating, but endpoints might be specific.
        // For general usage:
        'id': id,
        'email': email,
        'nombre': name,
        'genero': gender,
        'edad_rango': age,
        'experiencia_padel': yearsPlaying,
        'categoria': category,
        'posicion_preferida': position,
        'horario_disponible': schedule,
        'localidad': locality,
        'biografia': biography,
      };

  // Handles flat structure (e.g. from /usuarios/buscar or inside /conexiones)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['usuario_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['nombre'] ?? '',
      gender: json['genero']?.toString() ?? '',
      age: (json['rango_edad'] ?? json['edad_rango'])?.toString() ?? '',
      yearsPlaying:
          int.tryParse(json['experiencia_padel']?.toString() ?? '0') ?? 0,
      category: json['categoria'] ?? '',
      position: json['posicion_preferida'] ?? '',
      schedule: json['horario_disponible'] ?? '',
      locality: json['localidad'] ?? '',
      biography: json['biografia'],
      profileImageUrl: json['foto_principal_url'] ?? json['foto'],
      createdAt: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
    );
  }

  // Handles nested structure from /usuarios/yo (datos: { usuario: {...}, perfil: {...}, fotos: [...] })
  factory UserModel.fromProfileJson(Map<String, dynamic> data) {
    final usuario = data['usuario'] ?? {};
    final perfil = data['perfil'] ?? {};
    // Depending on logic, fotos might specific which is is_principal
    // But usually profile fetches generic info.
    // If backend sends 'fotos' list, we might pick the main one.
    String? mainPhoto;
    if (data['fotos'] is List) {
      final main = (data['fotos'] as List).firstWhere(
          (f) => f['es_principal'] == true || f['es_principal'] == 1,
          orElse: () => null);
      if (main != null) mainPhoto = main['url'];
    }

    return UserModel(
      id: usuario['id'] ?? '',
      email: usuario['email'] ?? '',
      name: perfil['nombre'] ?? '',
      gender: perfil['genero'] ?? '',
      age: perfil['rango_edad'] ??
          perfil['edad_rango'] ??
          '', // Check backend naming for profile update vs get
      yearsPlaying:
          int.tryParse(perfil['experiencia_padel']?.toString() ?? '0') ?? 0,
      category: perfil['categoria'] ?? '',
      position: perfil['posicion_preferida'] ?? '',
      schedule: perfil['horario_disponible'] ?? '',
      locality: perfil['localidad'] ?? '',
      biography: perfil['biografia'],
      profileImageUrl: mainPhoto,
    );
  }

  UserModel copyWith({
    String? name,
    String? gender,
    String? age,
    int? yearsPlaying,
    String? category,
    String? position,
    String? schedule,
    String? locality,
    String? biography,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      yearsPlaying: yearsPlaying ?? this.yearsPlaying,
      category: category ?? this.category,
      position: position ?? this.position,
      schedule: schedule ?? this.schedule,
      locality: locality ?? this.locality,
      biography: biography ?? this.biography,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
