import '../emojis/emojis.dart';

/// Curated, categorised emoji set for the emoji panel.
///
/// The Smileys / Gestures / Hearts categories reference the vendored
/// [Emojis] constants (zero runtime dependency); the remaining categories use
/// literal glyphs. Skin-tone and ZWJ variants are intentionally omitted to keep
/// the grid clean — use [Emojis] directly for the full set.
class EmojiData {
  const EmojiData._();

  static const Map<String, List<String>> categories = {
    'Smileys': _smileys,
    'Gestures': _gestures,
    'Hearts': _hearts,
    'Animals': _animals,
    'Food': _food,
    'Travel': _travel,
    'Activities': _activities,
    'Objects': _objects,
    'Symbols': _symbols,
  };

  static const List<String> _smileys = [
    Emojis.grinningFace, Emojis.grinningFaceWithBigEyes,
    Emojis.grinningFaceWithSmilingEyes, Emojis.beamingFaceWithSmilingEyes,
    Emojis.grinningSquintingFace, Emojis.grinningFaceWithSweat,
    Emojis.rollingOnTheFloorLaughing, Emojis.faceWithTearsOfJoy,
    Emojis.slightlySmilingFace, Emojis.upsideDownFace, Emojis.winkingFace,
    Emojis.smilingFaceWithSmilingEyes, Emojis.smilingFaceWithHalo,
    Emojis.smilingFaceWithHearts, Emojis.smilingFaceWithHeartEyes,
    Emojis.starStruck, Emojis.faceBlowingAKiss, Emojis.kissingFace,
    Emojis.faceSavoringFood, Emojis.faceWithTongue, Emojis.winkingFaceWithTongue,
    Emojis.zanyFace, Emojis.moneyMouthFace, Emojis.faceWithHandOverMouth,
    Emojis.shushingFace, Emojis.thinkingFace, Emojis.zipperMouthFace,
    Emojis.faceWithRaisedEyebrow, Emojis.neutralFace, Emojis.expressionlessFace,
    Emojis.smirkingFace, Emojis.unamusedFace, Emojis.faceWithRollingEyes,
    Emojis.grimacingFace, Emojis.lyingFace, Emojis.relievedFace,
    Emojis.pensiveFace, Emojis.sleepyFace, Emojis.droolingFace,
    Emojis.sleepingFace, Emojis.faceWithMedicalMask, Emojis.faceWithThermometer,
    Emojis.nauseatedFace, Emojis.faceVomiting, Emojis.sneezingFace,
    Emojis.hotFace, Emojis.coldFace, Emojis.woozyFace, Emojis.explodingHead,
    Emojis.cowboyHatFace, Emojis.partyingFace, Emojis.disguisedFace,
    Emojis.smilingFaceWithSunglasses, Emojis.nerdFace, Emojis.faceWithMonocle,
    Emojis.confusedFace, Emojis.worriedFace, Emojis.slightlyFrowningFace,
    Emojis.faceWithOpenMouth, Emojis.hushedFace, Emojis.astonishedFace,
    Emojis.flushedFace, Emojis.pleadingFace, Emojis.fearfulFace,
    Emojis.anxiousFaceWithSweat, Emojis.cryingFace, Emojis.loudlyCryingFace,
    Emojis.faceScreamingInFear, Emojis.confoundedFace, Emojis.perseveringFace,
    Emojis.disappointedFace, Emojis.wearyFace, Emojis.tiredFace,
    Emojis.yawningFace, Emojis.faceWithSteamFromNose, Emojis.enragedFace,
    Emojis.angryFace, Emojis.faceWithSymbolsOnMouth, Emojis.smilingFaceWithHorns,
    Emojis.angryFaceWithHorns, Emojis.skull, Emojis.pileOfPoo, Emojis.clownFace,
    Emojis.ghost, Emojis.alien, Emojis.alienMonster, Emojis.robot,
  ];

  static const List<String> _gestures = [
    Emojis.wavingHand, Emojis.raisedBackOfHand, Emojis.handWithFingersSplayed,
    Emojis.raisedHand, Emojis.vulcanSalute, Emojis.okHand, Emojis.pinchedFingers,
    Emojis.pinchingHand, Emojis.victoryHand, Emojis.crossedFingers,
    Emojis.loveYouGesture, Emojis.signOfTheHorns, Emojis.callMeHand,
    Emojis.backhandIndexPointingLeft, Emojis.backhandIndexPointingRight,
    Emojis.backhandIndexPointingUp, Emojis.backhandIndexPointingDown,
    Emojis.indexPointingUp, Emojis.thumbsUp, Emojis.thumbsDown,
    Emojis.raisedFist, Emojis.oncomingFist, Emojis.leftFacingFist,
    Emojis.rightFacingFist, Emojis.clappingHands, Emojis.raisingHands,
    Emojis.openHands, Emojis.palmsUpTogether, Emojis.handshake,
    Emojis.foldedHands, Emojis.writingHand, Emojis.nailPolish, Emojis.selfie,
    Emojis.flexedBiceps, Emojis.leg, Emojis.foot, Emojis.ear, Emojis.nose,
    Emojis.brain, Emojis.eyes, Emojis.eye, Emojis.tongue, Emojis.mouth,
  ];

  static const List<String> _hearts = [
    Emojis.redHeart, Emojis.orangeHeart, Emojis.yellowHeart, Emojis.greenHeart,
    Emojis.blueHeart, Emojis.lightBlueHeart, Emojis.purpleHeart,
    Emojis.brownHeart, Emojis.blackHeart, Emojis.greyHeart, Emojis.whiteHeart,
    Emojis.pinkHeart, Emojis.brokenHeart, Emojis.heartExclamation,
    Emojis.twoHearts, Emojis.revolvingHearts, Emojis.beatingHeart,
    Emojis.growingHeart, Emojis.sparklingHeart, Emojis.heartWithArrow,
    Emojis.heartWithRibbon, Emojis.heartDecoration, Emojis.kissMark,
    Emojis.hundredPoints, Emojis.collision, Emojis.dizzy, Emojis.sweatDroplets,
    Emojis.dashingAway, Emojis.speechBalloon, Emojis.thoughtBalloon, Emojis.zzz,
  ];

  static const List<String> _animals = [
    '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵',
    '🐔','🐧','🐦','🐤','🦆','🦅','🦉','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐢',
    '🐍','🐙','🦑','🦀','🐠','🐟','🐬','🐳','🐋','🦈','🐊','🐅','🐆','🦓','🦍',
    '🐘','🦏','🐪','🐫','🦒','🐃','🐂','🐄','🐎','🐖','🐏','🐑','🐐','🦌','🐕',
  ];

  static const List<String> _food = [
    '🍏','🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑','🥭','🍍',
    '🥥','🥝','🍅','🍆','🥑','🥦','🥬','🥒','🌶','🌽','🥕','🧄','🧅','🥔','🍠',
    '🥐','🍞','🥖','🥨','🧀','🥚','🍳','🧈','🥞','🧇','🥓','🍔','🍟','🍕','🌭',
    '🌮','🌯','🥗','🍜','🍲','🍣','🍱','🍙','🍚','🍰','🎂','🍦','🍩','🍪','🍫',
  ];

  static const List<String> _travel = [
    '🚗','🚕','🚙','🚌','🚎','🏎','🚓','🚑','🚒','🚐','🚚','🚛','🚜','🛵','🏍',
    '🚲','🛴','🚨','🚔','🚍','✈️','🛫','🛬','🚀','🛸','🚁','⛵','🚤','🛳','⛴',
    '🚢','⚓','🚂','🚆','🚊','🚉','🗽','🗼','🏰','🏯','🏟','🎡','🎢','🎠','⛱',
  ];

  static const List<String> _activities = [
    '⚽','🏀','🏈','⚾','🥎','🎾','🏐','🏉','🥏','🎱','🪀','🏓','🏸','🥅','⛳',
    '🏹','🎣','🥊','🥋','🎽','⛸','🥌','🛷','🎿','🏂','🏋️','🤸','🤼','🤽','🤾',
    '🚴','🚵','🏆','🥇','🥈','🥉','🏅','🎖','🎯','🎮','🎲','🎰','🎳','🎬','🎤',
  ];

  static const List<String> _objects = [
    '⌚','📱','💻','⌨️','🖥','🖨','🖱','🕹','💾','💿','📷','📸','🎥','📹','📺',
    '🔋','🔌','💡','🔦','🕯','💸','💵','💳','🔧','🔨','🪛','⚙️','🔩','🧲','🔫',
    '💊','💉','🩺','🔬','🔭','📡','🪑','🚪','🛏','🚽','🚿','🛁','🧴','🧷','🔑',
  ];

  static const List<String> _symbols = [
    '❤️','🧡','💛','💚','💙','💜','🖤','🤍','💯','✅','❌','⭕','🔴','🟠','🟡',
    '🟢','🔵','🟣','⚫','⚪','🔺','🔻','🔶','🔷','✨','⭐','🌟','💫','⚡','🔥',
    '➕','➖','➗','✖️','❓','❗','‼️','⁉️','💲','©️','®️','™️','🔔','🔕','🎵',
  ];
}
