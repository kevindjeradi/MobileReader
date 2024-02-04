class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final double progress;
  final int chaptersCount;
  final bool favorite;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.progress,
    required this.chaptersCount,
    this.favorite = false,
  });
}

final List<Book> mockDataBooks = [
  Book(
    id: '1',
    title: 'When A Mage Revolts',
    author: 'Yin Si',
    coverUrl: 'https://via.placeholder.com/100x150',
    progress: 0.8,
    description:
        "Kubei was just an ordinary pencil and button pusher working a day job, hating his boss and making horrible speeches when one day he fell asleep after pushing an all-nighter. When he woke up, he was bound to a chair, facing three creepy robed women and in a body way too young and way too weak to be his own. As he slowly came to, he realized that he was no longer in the same universe as he was before. He had teleported to the Kingdom of Helius, where an all-powerful church rules its lands and wages war against the elusive group known only as Mages. Armed with an incredibly cocky neural interface that just won’t shut up and his own sheer wit, our MC will find himself not just fighting to survive, but maybe even something bigger than himself.",
    chaptersCount: 70,
  ),
  Book(
    id: '2',
    title: 'True Martial World',
    author: 'Cocooned Cow',
    coverUrl: 'https://via.placeholder.com/100x150',
    progress: 0.98,
    favorite: true,
    description:
        "With the strongest experts from the 33 Skies the Human Emperor, Lin Ming, and his opponent, the Abyssal Demon King, were embroiled in a final battle. In the end, the Human Emperor destroyed the Abyssal World and killed the Abyssal Demon King. By then, a godly artifact, the mysterious purple card that had previously sealed the Abyssal Demon King, had long since disappeared into the space-time vortex, tunneling through infinite spacetime together with one of Lin Ming's loved ones. In the vast wilderness, where martial arts was still slowly growing in its infancy, several peerless masters tried to find their path in the world of martial arts. A young adult named Yi Yun from modern Earth unwittingly stumbles into such a world and begins his journey with a purple card of unknown origin. This is a magnificent yet unknown true martial world! This is the story of a normal young adult and his adventures!! ",
    chaptersCount: 10,
  ),
];
