# Balancing sheet — prototype

10 configured plants; not the final 150-item catalog. No paid/random rarity odds are implemented.

| ID | Name | Rarity | Seed Coins | Growth seconds | Normal sale | Mutant sale |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| sprout | Happy Sprout | Common | 10 | 10 | 15 | 30 |
| carrot | Dancing Carrot | Common | 25 | 30 | 40 | 80 |
| mushroom | Sleepy Mushroom | Common | 50 | 60 | 85 | 170 |
| cactus | Disco Cactus | Uncommon | 100 | 90 | 180 | 360 |
| moonflower | Moon Flower | Uncommon | 200 | 120 | 380 | 760 |
| crystal | Crystal Bloom | Rare | 500 | 180 | 1000 | 2000 |
| dragon | Dragon Fruit | Rare | 1000 | 240 | 2100 | 4200 |
| phoenix | Phoenix Fern | Legendary | 2500 | 360 | 5500 | 11000 |
| nebula | Nebula Lotus | Mythical | 10000 | 600 | 23000 | 46000 |
| brainbloom | Brain Bloom | BrainrotSecret | 50000 | 1200 | 120000 | 240000 |

Starter: 100 Coins. Inventory cap: 500 seeds and 500 crops. 8 slots per plot.

Fusion: 3 identical normal crops + 100 Coins → 1 mutant, sale value = normal × 2. This is a collection/economy sink: selling the three normals pays more than fusing. Random traits and mutant replanting are not implemented.

Growth ready-at = server planted-at + configured growth time. Offline growth is elapsed real time, not passive currency generation.

Daily Coins: 50, 100, 150, 200, 250, 300, 500; day 7 also adds a Crystal seed if seed capacity allows. Missed UTC day resets streak.

Daily goals: Harvest 10, Steal 2 (disabled/hidden), Fuse 1. Each claim: 150 Coins + 5 Gems + 100 XP. Harvest: 10 XP.

Free season: 30 UTC days, 50 tiers, threshold = tier × 100 XP. Tier reward = tier × 50 Coins. Premium track absent.

All production balance sources are in src/shared/Config. No retention, revenue or rarity-drop guarantee is made.
