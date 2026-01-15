import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/my_plant_controller.dart';

class MyPlantView extends GetView<MyPlantController> {
  const MyPlantView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.plants.isEmpty && controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Plant',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.plants.length} plants in your list',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showAddPlantDialog(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (controller.plants.isEmpty) ...[
                _buildEmptyState(context),
              ] else ...[
                Text(
                  'Saved plants',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.plants.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final plant = controller.plants[index];
                      return _buildPlantCard(context, plant);
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'All plants',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...controller.plants.map(
                  (plant) => _buildCompactTile(context, plant),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist, size: 72, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              'No plants added yet',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your plant by name and we will fetch the image and details for you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.local_florist, color: Colors.green),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_florist, color: Colors.green),
          );
        },
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, PlantEntry plant) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: plant.imageUrl.isEmpty
                ? Container(
                    height: 90,
                    color: Colors.green.withOpacity(0.08),
                    child: const Center(
                      child: Icon(Icons.local_florist, color: Colors.green),
                    ),
                  )
                : Image.network(
                    plant.imageUrl,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            plant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            plant.shortDescription.isNotEmpty
                ? plant.shortDescription
                : (plant.description.isNotEmpty
                      ? plant.description
                      : 'Saved plant'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTile(BuildContext context, PlantEntry plant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: InkWell(
        onTap: () => _showPlantDetails(context, plant),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _buildImage(plant.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.shortDescription.isNotEmpty
                        ? plant.shortDescription
                        : (plant.description.isNotEmpty
                              ? plant.description
                              : 'Saved plant'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPlantDetails(BuildContext context, PlantEntry plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: plant.imageUrl.isEmpty
                          ? Container(
                              height: 200,
                              color: Colors.green.withOpacity(0.08),
                              child: const Center(
                                child: Icon(
                                  Icons.local_florist,
                                  color: Colors.green,
                                  size: 48,
                                ),
                              ),
                            )
                          : Image.network(
                              plant.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      plant.name,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailsSection(plant),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.removePlant(plant.id);
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsSection(PlantEntry plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (plant.shortDescription.isNotEmpty)
              _buildChip(plant.shortDescription, Colors.green),
            if (plant.pageType.isNotEmpty)
              _buildChip(plant.pageType.replaceAll('_', ' '), Colors.blueGrey),
            if (plant.sourceUrl.isNotEmpty)
              _buildChip('Wikipedia', Colors.blue),
            if (plant.plantAge.isNotEmpty)
              _buildChip('Age: ${plant.plantAge}', Colors.teal),
            if (plant.location.isNotEmpty)
              _buildChip('Location: ${plant.location}', Colors.deepPurple),
            if (plant.variety.isNotEmpty)
              _buildChip('Variety: ${plant.variety}', Colors.orange),
          ],
        ),
        const SizedBox(height: 12),
        if (plant.notes.isNotEmpty) ...[
          Text(
            'Your Notes',
            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            plant.notes,
            style: GoogleFonts.lato(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          'About',
          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          plant.description.isNotEmpty
              ? plant.description
              : 'No description available.',
          style: GoogleFonts.lato(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[700],
          ),
        ),
        if (plant.sourceUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Source',
            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          SelectableText(
            plant.sourceUrl,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.blueGrey[700]),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _showAddPlantDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final varietyController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add New Plant',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plant name',
                        hintText: 'e.g., Tomato',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'Plant age',
                        hintText: 'e.g., 3 weeks',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: varietyController,
                      decoration: const InputDecoration(
                        labelText: 'Variety',
                        hintText: 'e.g., Cherry Tomato',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., Greenhouse A',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Any special care notes',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.addPlant(
                                nameController.text,
                                plantAge: ageController.text,
                                variety: varietyController.text,
                                location: locationController.text,
                                notes: notesController.text,
                              );
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
