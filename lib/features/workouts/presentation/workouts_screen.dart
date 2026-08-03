import 'package:flutter/material.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  // Controle simples para saber qual ficha está selecionada na tela
  String _selectedFicha = 'A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Meus Treinos', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Seletor de Fichas (A, B, C...)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFichaSelector('A', 'Peito & Tríceps'),
                const SizedBox(width: 12),
                _buildFichaSelector('B', 'Costas & Bíceps'),
                const SizedBox(width: 12),
                _buildFichaSelector('C', 'Pernas & Ombro'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Resumo do Treino Selecionado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ficha $_selectedFicha - Exercícios', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                Text(
                  'Aprox. 45 min',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          // Lista de Exercícios (Muda dependendo da ficha, aqui está fixo para visualização)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildExerciseCard('Supino Reto', 'Barra livre', '4', '10 a 12', '20kg - 20kg'),
                _buildExerciseCard('Supino Inclinado', 'Halteres', '3', '10', '16kg'),
                _buildExerciseCard('Crucifixo Máquina', 'Peck Deck', '3', 'FALHA', '35kg'),
                _buildExerciseCard('Tríceps Pulley', 'Cabo - Barra Reta', '4', '12', '25kg'),
                _buildExerciseCard('Tríceps Testa', 'Halteres', '3', '10', '10kg'),
                const SizedBox(height: 80), // Espaço para o botão flutuante não tampar o último item
              ],
            ),
          ),
        ],
      ),
      
      // Botão Flutuante para Iniciar o Treino
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Lógica para iniciar cronômetro/modo treino
        },
        backgroundColor: Colors.black87,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Iniciar Treino', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildFichaSelector(String ficha, String title) {
    bool isSelected = _selectedFicha == ficha;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFicha = ficha;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.black87 : Colors.grey.shade300),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(
          children: [
            Text(
              'Ficha $ficha',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(String name, String details, String sets, String reps, String weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // Imagem/Ícone do exercício (Usando placeholder)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=200&auto=format&fit=crop'),
                fit: BoxFit.cover,
              )
            ),
          ),
          const SizedBox(width: 16),
          
          // Informações do exercício
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(details, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 12),
                
                // Tags de Séries, Repetições e Carga
                Row(
                  children: [
                    _buildTag('${sets}x $reps', Colors.blue),
                    const SizedBox(width: 8),
                    _buildTag(weight, Colors.orange),
                  ],
                )
              ],
            ),
          ),
          
          // Checkbox para marcar como feito
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.grey, size: 28),
            onPressed: () {
              // Lógica de marcar exercício
            },
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color[700], fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}