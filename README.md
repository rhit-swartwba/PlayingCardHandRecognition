# PlayingCardHandRecognition

This is the main branch containing all of the card generation, final YOLOv8 detector, and Blackjack player code.

To generate a dataset run:
- [Alpha Image Generator](./MakeAlphaImages.m) : Takes cards with green background and turnes the green into transparent pixels
- [Image Resizer](./ImageResizer.m) : Resizes images in a backgrounds folder to be used for YOLOv8 training
- [Dataset Generator](./DatasetGenerator.m) : Generates .png images with combinations of backgrounds and cards along with .txt annotation files
- [Bounding Box Inspector](./BoundingBox.m) : Shows image of background and cards with bounding boxes drawn on image for verification

To train a the YOLOv8 model run:
- [Data Preparation](./DataPreparation.ipynb) : Seperates dataset into a training, validation, and testing set
- [YOLOv8](./YOLOv8.ipynb) : Trains the YOLOv8m model on dataset

To run the live Blackjack detector:
- [Blackjack](./Blackjack.ipynb) : Runs application that uses the trained YOLO model to help player win Blackjack
   