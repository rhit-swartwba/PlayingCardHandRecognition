class BlackjackPlayer:
    hard_value_map = \
        {"2C": 2, "3C": 3, "4C": 4, "5C": 5, "6C": 6, "7C": 7, "8C": 8, "9C": 9, "10C": 10, "JC": 10, "QC": 10,
         "KC": 10, "AC": 11,
         "2D": 2, "3D": 3, "4D": 4, "5D": 5, "6D": 6, "7D": 7, "8D": 8, "9D": 9, "10D": 10, "JD": 10, "QD": 10,
         "KD": 10, "AD": 11,
         "2H": 2, "3H": 3, "4H": 4, "5H": 5, "6H": 6, "7H": 7, "8H": 8, "9H": 9, "10H": 10, "JH": 10, "QH": 10,
         "KH": 10, "AH": 11,
         "2S": 2, "3S": 3, "4S": 4, "5S": 5, "6S": 6, "7S": 7, "8S": 8, "9S": 9, "10S": 10, "JS": 10, "QS": 10,
         "KS": 10, "AS": 11}

    soft_value_map = \
        {"2C": 2, "3C": 3, "4C": 4, "5C": 5, "6C": 6, "7C": 7, "8C": 8, "9C": 9, "10C": 10, "JC": 10, "QC": 10,
         "KC": 10, "AC": 1,
         "2D": 2, "3D": 3, "4D": 4, "5D": 5, "6D": 6, "7D": 7, "8D": 8, "9D": 9, "10D": 10, "JD": 10, "QD": 10,
         "KD": 10, "AD": 1,
         "2H": 2, "3H": 3, "4H": 4, "5H": 5, "6H": 6, "7H": 7, "8H": 8, "9H": 9, "10H": 10, "JH": 10, "QH": 10,
         "KH": 10, "AH": 1,
         "2S": 2, "3S": 3, "4S": 4, "5S": 5, "6S": 6, "7S": 7, "8S": 8, "9S": 9, "10S": 10, "JS": 10, "QS": 10,
         "KS": 10, "AS": 1}

    command_map = {"S": "Stand", "H": "Hit", "D": "Double if allowed, otherwise Hit",
                   "Ds": "Double if allowed, otherwise Stand"}

    aces = ["AS", "AH", "AD", "AC"]

    hard_play = \
        {
            21: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            20: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            19: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            18: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            17: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            16: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            15: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            14: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            13: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            12: {2: "H", 3: "H", 4: "S", 5: "S", 6: "S", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            11: {2: "D", 3: "D", 4: "D", 5: "D", 6: "D", 7: "D", 8: "D", 9: "D", 10: "D", 11: "D"},
            10: {2: "D", 3: "D", 4: "D", 5: "D", 6: "D", 7: "D", 8: "D", 9: "D", 10: "S", 11: "S"},
            9: {2: "H", 3: "D", 4: "D", 5: "D", 6: "D", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            8: {2: "H", 3: "H", 4: "H", 5: "H", 6: "H", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            7: {2: "H", 3: "H", 4: "H", 5: "H", 6: "H", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            6: {2: "H", 3: "H", 4: "H", 5: "H", 6: "H", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            5: {2: "H", 3: "H", 4: "H", 5: "H", 6: "H", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            4: {2: "H", 3: "H", 4: "H", 5: "H", 6: "H", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
        }

    soft_play = \
        {
            9: {2: "S", 3: "S", 4: "S", 5: "S", 6: "S", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            8: {2: "S", 3: "S", 4: "S", 5: "S", 6: "Ds", 7: "S", 8: "S", 9: "S", 10: "S", 11: "S"},
            7: {2: "Ds", 3: "Ds", 4: "Ds", 5: "Ds", 6: "Ds", 7: "S", 8: "S", 9: "H", 10: "H", 11: "H"},
            6: {2: "H", 3: "D", 4: "D", 5: "D", 6: "D", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            5: {2: "H", 3: "H", 4: "D", 5: "D", 6: "D", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            4: {2: "H", 3: "H", 4: "D", 5: "D", 6: "D", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            3: {2: "H", 3: "H", 4: "H", 5: "D", 6: "D", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
            2: {2: "H", 3: "H", 4: "H", 5: "D", 6: "D", 7: "H", 8: "H", 9: "H", 10: "H", 11: "H"},
        }

    split = \
        {
            11: {2: "Y", 3: "Y", 4: "Y", 5: "Y", 6: "Y", 7: "Y", 8: "Y", 9: "Y", 10: "Y", 11: "Y"},
            10: {2: "N", 3: "N", 4: "N", 5: "N", 6: "N", 7: "N", 8: "N", 9: "N", 10: "N", 11: "N"},
            9: {2: "Y", 3: "Y", 4: "Y", 5: "Y", 6: "Y", 7: "N", 8: "Y", 9: "Y", 10: "N", 11: "N"},
            8: {2: "Y", 3: "Y", 4: "Y", 5: "Y", 6: "Y", 7: "Y", 8: "Y", 9: "Y", 10: "Y", 11: "Y"},
            7: {2: "Y", 3: "Y", 4: "Y", 5: "Y", 6: "Y", 7: "Y", 8: "N", 9: "N", 10: "N", 11: "N"},
            6: {2: "N", 3: "Y", 4: "Y", 5: "Y", 6: "Y", 7: "N", 8: "N", 9: "N", 10: "N", 11: "N"},
            5: {2: "N", 3: "N", 4: "N", 5: "N", 6: "N", 7: "N", 8: "N", 9: "N", 10: "N", 11: "N"},
            4: {2: "N", 3: "N", 4: "N", 5: "N", 6: "N", 7: "N", 8: "N", 9: "N", 10: "N", 11: "N"},
            3: {2: "N", 3: "N", 4: "Y", 5: "Y", 6: "Y", 7: "Y", 8: "N", 9: "N", 10: "N", 11: "N"},
            2: {2: "N", 3: "N", 4: "Y", 5: "Y", 6: "Y", 7: "Y", 8: "N", 9: "N", 10: "N", 11: "N"},
        }

    def __init__(self, dealer_list, player_list, class_dict):
        self.dealer_list = dealer_list
        self.player_list = player_list
        self.class_dict = class_dict

    def play(self):
        player_card_list = [self.class_dict[card] for card in self.player_list]
        dealer_card_list = [self.class_dict[card] for card in self.dealer_list]

        if len(player_card_list) < 2:
            return "Missing player cards"

        if len(dealer_card_list) == 0:
            return "Waiting on dealer"

        if len(dealer_card_list) >= 2:
            if self.hand_hard_sum(player_card_list) > 21:
                player_val = self.hand_soft_sum(player_card_list)
            else:
                player_val = self.hand_hard_sum(player_card_list)

            if self.hand_hard_sum(dealer_card_list) > 21:
                dealer_val = self.hand_soft_sum(dealer_card_list)
            else:
                dealer_val = self.hand_hard_sum(dealer_card_list)

            if player_val > 21:
                return "Defeat :("

            if dealer_val > 21:
                return "Victory! :)"

            if player_val == dealer_val:
                return "Push :/"
            elif player_val > dealer_val:
                return "Victory! :)"
            else:
                return "Defeat :("

        if len(player_card_list) == 2:
            if self.hand_hard_sum(player_card_list) == 21:
                return "BLACKJACK!"
            if self.hard_value_map[player_card_list[0]] == self.hard_value_map[player_card_list[1]]:
                if self.split[self.hard_value_map[player_card_list[0]][self.hard_value_map[dealer_card_list[0]]]] == "Y":
                    return "Split"

        if len(player_card_list) >= 2:
            if self.hand_soft_sum(player_card_list) > 21:
                return "Defeat :("
            if any(card in player_card_list for card in self.aces):
                list_no_aces = [card for card in player_card_list if card not in self.aces]
                return self.command_map[
                    self.soft_play[self.hand_hard_sum(list_no_aces)][self.hand_hard_sum(dealer_card_list)]
                ]
            if self.hand_hard_sum(player_card_list) > 21:
                return "Defeat :("
            return self.command_map[
                self.hard_play[self.hand_hard_sum(player_card_list)][self.hand_hard_sum(dealer_card_list)]
            ]

        return "Unknown"

    def hand_hard_sum(self, cards):
        sum = 0
        for card in cards:
            sum += self.hard_value_map[card]
        return sum

    def hand_soft_sum(self, cards):
        sum = 0
        for card in cards:
            sum += self.soft_value_map[card]
        return sum
