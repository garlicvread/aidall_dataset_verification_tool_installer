# Braille Blocks Image-Annotation Dataset Documentation
© 2024 AidALL Inc. All rights reserved.

## License and Usage Rights

### Copyright Notice
© 2024 AidALL Inc. All rights reserved.

### Proprietary Notice
THIS IS A PROPRIETARY DATASET OF AIDALL INC. IT IS NOT FOR PUBLIC DISTRIBUTION.

### Intellectual Property Rights
- All intellectual property rights, including but not limited to copyrights, patents, trademarks, and trade secrets in this dataset and associated documentation, are owned exclusively by AidALL Inc.
- This dataset was created under contract by 주식회사 스트롱시프트, and all rights were transferred to AidALL Inc. upon delivery on December 31, 2024.

### Confidentiality and Usage Restrictions
1. **Unauthorized Access and Usage**
   - This dataset is confidential and proprietary to AidALL Inc.
   - Any unauthorized access, possession, or use of this dataset is strictly prohibited.
   - In case of unauthorized distribution or leak, immediate deletion of all copies is required.
   - Legal action will be taken against any unauthorized use or possession of this dataset.

2. **Licensed Usage**
   - Usage rights can only be obtained through a valid license purchase from AidALL Inc.
   - Licensed users must comply with all terms and conditions specified in their license agreement.
   - Contact AidALL Inc. for licensing options and pricing.

3. **Prohibited Actions**
   - Unauthorized copying, sharing, or distribution of the dataset.
   - Reverse engineering or attempting to extract the underlying data structure.
   - Creating derivative works without explicit permission.
   - Using the dataset beyond the scope of the purchased license.

### Legal Disclaimer
- Any unauthorized possession or use of this dataset may result in civil and criminal penalties.
- AidALL Inc. reserves all rights to pursue legal remedies against unauthorized use.
- The dataset is provided “as is,” without warranty of any kind, to licensed users.
- AidALL Inc. reserves the right to modify these terms at any time.

For licensing inquiries or to report unauthorized use, please contact AidALL Inc.

## Dataset Overview
- **Name**: Braille Detection Dataset
- **Version**: 1.0
- **Creation Date**: December 31, 2024
- **Last Updated**: December 31, 2024
- **Created by**: 주식회사 스트롱시프트

## Dataset Description
This dataset is a collection of high-resolution braille images and their corresponding annotations for polygon segmentation tasks. The braille text images were captured using a professional-grade camera system under controlled lighting.

## Dataset Structure
### Directory Organization

```
dataset/
├── imgs/               # Image directory
│   ├── braille_b_00001.png
│   ├── braille_b_00002.png
│   └── ...
└── annotations/        # Annotation directory
    ├── braille_b_00001.json
    ├── braille_b_00002.json
    └── ...
```

### File Formats
1. **Images**
   - Format: PNG
   - Naming Convention: `braille_b_XXXXX.png` (5-digit sequential numbering)

2. **Annotations**
   - Format: JSON
   - Naming Convention: `braille_b_XXXXX.json` (matches the corresponding image filename)
   - Schema Example:
     ```json
     {
       "version": "5.5.0",
       "flags": {},
       "shapes": [
         {
           "label": "braille_b_d",
           "points": [
             [0.0, 1249.8],
             [1.3, 1587.7],
             [3019.5, 1640.7],
             [3018.0, 1365.0]
           ],
           "shape_type": "polygon"
         },
         // Additional shapes possible
         {
           "label": "braille_b_d",
           "points": [
             [100.0, 200.0],
             [150.0, 200.0],
             [150.0, 250.0],
             [100.0, 250.0],
             [75.0, 225.0]
           ],
           "shape_type": "polygon"
         }
       ],
       "imagePath": "braille_b_00001.png",
       "imageData": null,
       "imageHeight": 3024,
       "imageWidth": 3024
     }
     ```

### Annotation Format Details
- **version**: LabelMe annotation tool version (e.g., 5.5.0).
- **shapes**: Array of annotated regions.
  - **label**: Identifies the type of braille region.
  - **points**: Array of [x, y] coordinates defining the polygon vertices. The origin (0,0) is at the top-left corner, with x increasing to the right and y increasing downward.
  - **shape_type**: Always "polygon" for this dataset.
- **imageHeight/imageWidth**: Original image dimensions in pixels (may vary per image).
- **imageData**: Kept null to reduce file size.

## Dataset Statistics
- Total number of images: 4,000 ea
- Total number of annotations: 4,000 ea
- Image resolution: Varies (refer to imageHeight and imageWidth values in each annotation file).

## Data Collection
### Equipment
- Professional high-resolution camera system
- Controlled lighting for optimal image clarity

### Annotation Process
- Manual polygon annotation of braille regions using LabelMe
- Thorough quality control to ensure accuracy
- Standardized naming conventions for both images and annotation files

## Usage Guidelines
### Recommended Applications
- Braille text detection
- Polygon segmentation model training
- OCR system development for braille

### Best Practices
- Maintain aspect ratio during image processing.
- Consider the polygon vertex ordering in annotations.
- Handle the null imageData field appropriately.

## Contact Information
- **Author**: 주식회사 스트롱시프트
- **Organization**: 주식회사 스트롱시프트

## Version History
- **v1.0 (2024-12-31)**: Initial dataset release. (Directory structure setting and quality inspection completed)

## Notes
- Image data has been normalized and standardized for consistency.
- Annotations use a polygon segmentation format.
- Data was annotated using the LabelMe tool.