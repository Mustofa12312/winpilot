import 'package:flutter/material.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/files/models/file_model.dart';

class FileListItem extends StatelessWidget {
  final FileItem file;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FileListItem({
    super.key,
    required this.file,
    required this.onTap,
    required this.onLongPress,
  });

  IconData get _icon {
    if (file.isDir) return Icons.folder_rounded;
    switch (file.extension) {
      case '.jpg':
      case '.png':
      case '.jpeg':
        return Icons.image_rounded;
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.mp4':
      case '.mkv':
        return Icons.movie_rounded;
      case '.mp3':
      case '.wav':
        return Icons.audiotrack_rounded;
      case '.zip':
      case '.rar':
        return Icons.folder_zip_rounded;
      case '.txt':
      case '.md':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get _iconColor {
    if (file.isDir) return WinPilotTheme.primaryBlue;
    switch (file.extension) {
      case '.jpg':
      case '.png':
      case '.jpeg':
        return WinPilotTheme.successGreen;
      case '.pdf':
        return WinPilotTheme.dangerRed;
      case '.zip':
      case '.rar':
        return WinPilotTheme.warningOrange;
      default:
        return WinPilotTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _iconColor.withValues(alpha: 0.15),
          borderRadius: Radii.mdBR,
        ),
        child: Icon(_icon, color: _iconColor, size: 24),
      ),
      title: Text(
        file.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: WinPilotTheme.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (!file.isDir) ...[
            Text(file.sizeFormatted, style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted)),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: WinPilotTheme.textMuted)),
            const SizedBox(width: 8),
          ],
          Text(
            '${file.modifiedAt.day}/${file.modifiedAt.month}/${file.modifiedAt.year}',
            style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted),
          ),
        ],
      ),
      trailing: const Icon(Icons.more_vert_rounded, color: WinPilotTheme.textMuted),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
