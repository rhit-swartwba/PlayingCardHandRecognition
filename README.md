# PlayingCardHandRecognition

The github contains a [Jupyter Notebook](https://github.com/rhit-swartwba/PlayingCardHandRecognition/blob/main/card_detector.ipynb) which includes the software pipeline to get label information from the YOLO images dataset as well as simple training code for the YOLOv5 model. 

It also contains the results of a training run for 3 epochs in the [Model2](https://github.com/rhit-swartwba/PlayingCardHandRecognition/tree/main/quick_model2) folder.
The folder contains: 
- Training and Validation examples
- Performance metric plots for Precision and Recall and a Confusion Matrix
- Loss/Precision curves over epochs in the results.png file
- Logged metrics in the results.csv file


The live detection script which does zoning and dealer vs player detection is [here](https://github.com/rhit-swartwba/PlayingCardHandRecognition/blob/main/live_zone_det.ipynb)
