import 'package:continua/core/const/app_color.dart';
import 'package:continua/features/home/domain/entities/course_entity.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CoursesCard extends StatelessWidget {
  final CourseEntity course;
  final double progressPercent;
  final VoidCallback? onTap;

  const CoursesCard({
    super.key,
    required this.course,
    required this.progressPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = (progressPercent.clamp(0, 100)) / 100;
    final hasProgress = progressPercent > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'course_thumbnail_${course.id}',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: course.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Appcolor.white,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Appcolor.textcolor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Appcolor.secondtextcolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Appcolor.primarycolor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: hasProgress ? clampedProgress.toDouble() : 1.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        hasProgress
                            ? Appcolor.primarycolor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasProgress
                        ? '${progressPercent.toStringAsFixed(0)}%'
                        : "Start Learning",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Appcolor.primarycolor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
