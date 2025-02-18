# PlayingCardHandRecognition

This branch contains the final scripts and some initial models I wrote. 

Here is a list to navigate the branch: 
- [Final Black Jack Player](./scripts/Blackjack_player.ipynb) : Contains entire final card detection and blackjack player pipeline
- [Object detection script](./scripts/obj_detection.ipynb) : Initial detection script (only performs and attaches detection results - no player or "dealer" / "player" zones)
- [Data Sorting / Cleanup](./scripts/card_detector.ipynb) : Done on [initial kaggle dataset](https://www.kaggle.com/datasets/andy8744/playing-cards-object-detection-dataset/data). Also trained initial models on this script - eventually pivoted away from the dataset.
- Yaml files [1](./scripts/fc_data.yaml) [2](./scripts/data.yaml) : Ultralytics' YOLO library uses them for information about test,training and validation images and labels' locations.
- Initial models ([good](./good_model2/), [quick](./quick_model2/)) I trained for preliminary work. 
   