import 'package:admin_app/UI/employee/profile/components/expandable_tile.dart';
import 'package:admin_app/UI/employee/profile/model/doc_model.dart';
import 'package:flutter/material.dart';

class DocumentSection extends StatelessWidget {
  final int documentStatus;
  final List<DocModel> documents;

  const DocumentSection({
    Key? key,
    required this.documents,
    required this.documentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600; // Adaptive layout for tablets

    List<DocModel> expiringDocs = _getExpiringDocuments(documents);

    return Column(
      children: [
        if (documentStatus != 0)
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: documentStatus == 1
                  ? Colors.orange.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning,
                    color: documentStatus == 1 ? Colors.orange : Colors.red,
                    size: screenWidth * 0.06),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    "⚠️ Some documents are about to expire. Please renew them soon!",
                    style: TextStyle(
                      color: documentStatus == 1 ? Colors.orange : Colors.red,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ExpandableTile(
          title: "Documents",
          icon: Icons.description,
          expandedContent: _buildDocumentList(context, documents),
        ),
      ],
    );
  }

  /// 🟡 **Filter Expiring Documents**
  List<DocModel> _getExpiringDocuments(List<DocModel> docs) {
    DateTime now = DateTime.now();
    return docs.where((doc) {
      if (doc.expiryDate.isEmpty) return false;
      DateTime expiry = DateTime.parse(doc.expiryDate);
      return expiry.isBefore(now.add(Duration(days: int.parse(doc.alertDays))));
    }).toList();
  }

  /// 📜 **Document List UI**
  Widget _buildDocumentList(BuildContext context, List<DocModel> docs) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    return Column(
      children: docs.map((doc) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: _getDocStatusColor(doc),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocTitle(context, doc),
              SizedBox(height: screenHeight * 0.005),
              _buildDocDetails(context, doc),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 🔹 **Document Title Row (Icon + Name + Warning if Expiring)**
  Widget _buildDocTitle(BuildContext context, DocModel doc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    bool isExpiring = _isExpiring(doc);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.insert_drive_file,
                color: Colors.black54, size: screenWidth * 0.06),
            SizedBox(width: screenWidth * 0.02),
            Text(
              doc.doc,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ],
        ),
        if (isExpiring)
          Icon(Icons.warning, color: Colors.red, size: screenWidth * 0.05),
      ],
    );
  }

  /// 📜 **Document Details (Number + Expiry Date)**
  Widget _buildDocDetails(BuildContext context, DocModel doc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (doc.docNo.isNotEmpty)
          Text(
            "Number: ${doc.docNo}",
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
        Text(
          "Expiry Date: ${doc.expiryDate.isEmpty ? 'N/A' : doc.expiryDate}",
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: _isExpiring(doc) ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 🟢 **Status Color Indicator**
  Color _getDocStatusColor(DocModel doc) {
    if (doc.expiryDate.isEmpty) return Colors.grey.shade200;
    DateTime expiry = DateTime.parse(doc.expiryDate);
    DateTime now = DateTime.now();
    if (expiry.isBefore(now)) return Colors.red.shade100;
    if (expiry.isBefore(now.add(Duration(days: int.parse(doc.alertDays))))) {
      return Colors.orange.shade100;
    }
    return Colors.green.shade100;
  }

  /// ⏳ **Check if a Document is Expiring**
  bool _isExpiring(DocModel doc) {
    if (doc.expiryDate.isEmpty) return false;
    DateTime expiry = DateTime.parse(doc.expiryDate);
    return expiry
        .isBefore(DateTime.now().add(Duration(days: int.parse(doc.alertDays))));
  }
}
