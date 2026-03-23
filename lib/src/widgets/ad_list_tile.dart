import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../styling_models/ad_list_tile_style.dart';

class AdListTile extends StatefulWidget {
  final AdListTileStyle style;
  final Widget? leading;
  final Widget? trailing;
  final String title;
  final String subtitle;

  const AdListTile({
    super.key,
    this.leading,
    this.trailing,
    required this.title,
    required this.subtitle,
    required this.style,
  });

  @override
  State<AdListTile> createState() => _AdListTileState();
}

class _AdListTileState extends State<AdListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.style.tileColor,
      padding: widget.style.contentPadding,
      height: widget.style.tileHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: widget.style.tileElementsAlignment,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 5),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: widget.style.tileTitleAlignment,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: widget.style.titleTextStyle,
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.subtitle,
                  style: widget.style.subtitleTextStyle,
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 5),
            widget.trailing!,
          ],
        ],
      ),
    );
  }
}
