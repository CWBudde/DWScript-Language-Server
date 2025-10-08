unit WHATWG.Html;

interface

uses
  ECMA.TypedArray, WHATWG.DOM, W3C.UIEvents,
  W3C.HighResolutionTime, W3C.Geometry;

type
  // LegacyUnenumerableNamedProperties
  JHTMLAllCollection = class external 'HTMLAllCollection'
  private
    function GetNamedItem(name: String): JElement; external array;
  public
    length: Integer;
    function namedItem(name: String): JElement;
    function namedItemAsCollection(name: String): JHTMLCollection;
    function item: JElement; overload;
    function item(nameOrItem: String): JElement; overload;
    function itemAsCollection: JHTMLCollection; overload; external 'item';
    function itemAsCollection(nameOrItem: String): JHTMLCollection; overload; external 'item';

    property Items[Name: String]: JElement read GetNamedItem; default;
  end;

  JRadioNodeList = class external 'RadioNodeList' (JNodeList)
  public
    value: String;
  end;

  JHTMLFormControlsCollection = class external 'HTMLFormControlsCollection' (JHTMLCollection)
  public
    function namedItem(name: String): JElement; overload;
    function namedItemAsRadioNodeList(name: String): JRadioNodeList; overload; external 'namedItem';
  end;

  // HTMLConstructor
  JHTMLElement = partial class external 'HTMLElement' (JElement)
  public
    title: String; { CEReactions }
    lang: String; { CEReactions }
    translate: Boolean; { CEReactions }
    dir: String; { CEReactions }
    hidden: Boolean; { CEReactions }
    tabIndex: Integer; { CEReactions }
    accessKey: String; { CEReactions }
    accessKeyLabel: String;
    draggable: Boolean; { CEReactions }
    spellcheck: Boolean; { CEReactions }
    innerText: String; { CEReactions,TreatNullAs=EmptyString }
    procedure click;
    procedure focus;
    procedure blur;
    procedure forceSpellCheck;
  end;

  // HTMLConstructor,NamedConstructor=Option( optional DOMString text , optional DOMString value , optional boolean defaultSelected = false , optional boolean selected = false)
  JHTMLOptionElement = partial class external 'HTMLOptionElement' (JHTMLElement)
  public
    disabled: Boolean; { CEReactions }
    label: String; { CEReactions }
    defaultSelected: Boolean; { CEReactions }
    selected: Boolean;
    value: String; { CEReactions }
    text: String; { CEReactions }
    index: Integer;
  end;

  // HTMLConstructor
  JHTMLOptGroupElement = class external 'HTMLOptGroupElement' (JHTMLElement)
  public
    disabled: Boolean; { CEReactions }
    label: String; { CEReactions }
  end;

  JHTMLOptionsCollection = class external 'HTMLOptionsCollection' (JHTMLCollection)
  private
    procedure SetItem(index: Integer; option: JHTMLOptionElement);
    function GetItem(index: Integer): JHTMLOptionElement; external array;
  public
    length: Integer;
    selectedIndex: Integer;
    procedure add(element: JHTMLOptionElement); overload;
    procedure add(element: JHTMLOptionElement; before: Integer); overload;
    procedure add(element: JHTMLOptionElement; before: JHTMLElement); overload;
    procedure add(element: JHTMLOptGroupElement); overload;
    procedure add(element: JHTMLOptGroupElement; before: Integer); overload;
    procedure add(element: JHTMLOptGroupElement; before: JHTMLElement); overload;
    procedure remove(&index: Integer);

    property Item[index: Integer]: JHTMLOptionElement read GetItem write SetItem; default;
  end;

  JDocumentReadyState = String;
  JDocumentReadyStateHelper = strict helper for JDocumentReadyState
    const Loading = 'loading';
    const Interactive = 'interactive';
    const Complete = 'complete';
  end;

  THTMLOrSVGScriptElement = Variant;  // TODO

  // OverrideBuiltins
  JDOMStringMap = class external 'DOMStringMap'
  private
    function GetNamedItem(name: String): String; external array;
    procedure SetNamedItem(name: String; value: String);
  public
    property Items[Name: String]: String read GetNamedItem write SetNamedItem; default;
  end;

  JHTMLUnknownElement = class external 'HTMLUnknownElement' (JHTMLElement)
  end;

  // HTMLConstructor
  JHTMLHtmlElement = class external 'HTMLHtmlElement' (JHTMLElement)
  public
    version: String; { CEReactions }
  end;

  JHTMLHeadElement = class external 'HTMLHeadElement' (JHTMLElement)
  end;

  // HTMLConstructor
  JHTMLTitleElement = class external 'HTMLTitleElement' (JHTMLElement)
  public
    text: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLBaseElement = class external 'HTMLBaseElement' (JHTMLElement)
  public
    href: String; { CEReactions }
    target: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLLinkElement = class external 'HTMLLinkElement' (JHTMLElement)
  public
    href: String; { CEReactions }
    crossOrigin: String; { CEReactions }
    rel: String; { CEReactions }
// TODO    &as: JRequestDestination; { CEReactions }
    relList: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    media: String; { CEReactions }
    nonce: String; { CEReactions }
    integrity: String; { CEReactions }
    hreflang: String; { CEReactions }
    &type: String; { CEReactions }
    sizes: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    referrerPolicy: String; { CEReactions }
    charset: String; { CEReactions }
    rev: String; { CEReactions }
    target: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLMetaElement = class external 'HTMLMetaElement' (JHTMLElement)
  public
    name: String; { CEReactions }
    httpEquiv: String; { CEReactions }
    content: String; { CEReactions }
    scheme: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLStyleElement = class external 'HTMLStyleElement' (JHTMLElement)
  public
    media: String; { CEReactions }
    nonce: String; { CEReactions }
    &type: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLBodyElement = partial class external 'HTMLBodyElement' (JHTMLElement)
  public
    text: String; { CEReactions,TreatNullAs=EmptyString }
    link: String; { CEReactions,TreatNullAs=EmptyString }
    vLink: String; { CEReactions,TreatNullAs=EmptyString }
    aLink: String; { CEReactions,TreatNullAs=EmptyString }
    bgColor: String; { CEReactions,TreatNullAs=EmptyString }
    background: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLHeadingElement = class external 'HTMLHeadingElement' (JHTMLElement)
  public
    align: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLParagraphElement = class external 'HTMLParagraphElement' (JHTMLElement)
  public
    align: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLHRElement = class external 'HTMLHRElement' (JHTMLElement)
  public
    align: String; { CEReactions }
    color: String; { CEReactions }
    noShade: Boolean; { CEReactions }
    size: String; { CEReactions }
    width: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLPreElement = class external 'HTMLPreElement' (JHTMLElement)
  public
    width: Integer; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLQuoteElement = class external 'HTMLQuoteElement' (JHTMLElement)
  public
    cite: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLOListElement = class external 'HTMLOListElement' (JHTMLElement)
  public
    reversed: Boolean; { CEReactions }
    start: Integer; { CEReactions }
    &type: String; { CEReactions }
    compact: Boolean; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLUListElement = class external 'HTMLUListElement' (JHTMLElement)
  public
    compact: Boolean; { CEReactions }
    &type: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLLIElement = class external 'HTMLLIElement' (JHTMLElement)
  public
    value: Integer; { CEReactions }
    &type: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLDListElement = class external 'HTMLDListElement' (JHTMLElement)
  public
    compact: Boolean; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLDivElement = class external 'HTMLDivElement' (JHTMLElement)
  public
    align: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLAnchorElement = class external 'HTMLAnchorElement' (JHTMLElement)
  public
    target: String; { CEReactions }
    download: String; { CEReactions }
    ping: String; { CEReactions }
    rel: String; { CEReactions }
    relList: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    hreflang: String; { CEReactions }
    &type: String; { CEReactions }
    text: String; { CEReactions }
    referrerPolicy: String; { CEReactions }
    coords: String; { CEReactions }
    charset: String; { CEReactions }
    name: String; { CEReactions }
    rev: String; { CEReactions }
    shape: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLDataElement = class external 'HTMLDataElement' (JHTMLElement)
  public
    value: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTimeElement = class external 'HTMLTimeElement' (JHTMLElement)
  public
    dateTime: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLSpanElement = class external 'HTMLSpanElement' (JHTMLElement)
  end;

  // HTMLConstructor
  JHTMLBRElement = class external 'HTMLBRElement' (JHTMLElement)
  public
    clear: String; { CEReactions }
  end;

  // NoInterfaceObject
  JHTMLHyperlinkElementUtils = class external 'HTMLHyperlinkElementUtils'
  public
    origin: String;
    protocol: String; { CEReactions }
    username: String; { CEReactions }
    password: String; { CEReactions }
    host: String; { CEReactions }
    hostname: String; { CEReactions }
    port: String; { CEReactions }
    pathname: String; { CEReactions }
    search: String; { CEReactions }
    hash: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLModElement = class external 'HTMLModElement' (JHTMLElement)
  public
    cite: String; { CEReactions }
    dateTime: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLPictureElement = class external 'HTMLPictureElement' (JHTMLElement)
  end;

  // HTMLConstructor
  JHTMLSourceElement = class external 'HTMLSourceElement' (JHTMLElement)
  public
    src: String; { CEReactions }
    &type: String; { CEReactions }
    srcset: String; { CEReactions }
    sizes: String; { CEReactions }
    media: String; { CEReactions }
  end;

  // HTMLConstructor,NamedConstructor=Image( optional unsigned long width , optional unsigned long height)
  JHTMLImageElement = class external 'HTMLImageElement' (JHTMLElement)
  public
    alt: String; { CEReactions }
    src: String; { CEReactions }
    srcset: String; { CEReactions }
    sizes: String; { CEReactions }
    crossOrigin: String; { CEReactions }
    useMap: String; { CEReactions }
    isMap: Boolean; { CEReactions }
    width: Integer; { CEReactions }
    height: Integer; { CEReactions }
    naturalWidth: Integer;
    naturalHeight: Integer;
    complete: Boolean;
    currentSrc: String;
    referrerPolicy: String; { CEReactions }
    name: String; { CEReactions }
    lowsrc: String; { CEReactions }
    align: String; { CEReactions }
    hspace: Integer; { CEReactions }
    vspace: Integer; { CEReactions }
    longDesc: String; { CEReactions }
    border: String; { CEReactions,TreatNullAs=EmptyString }
  end;

  JWindowProxy = Variant;

  // HTMLConstructor
  JHTMLIFrameElement = class external 'HTMLIFrameElement' (JHTMLElement)
  public
    src: String; { CEReactions }
    srcdoc: String; { CEReactions }
    name: String; { CEReactions }
    sandbox: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    allowFullscreen: Boolean; { CEReactions }
    allowUserMedia: Boolean; { CEReactions }
    width: String; { CEReactions }
    height: String; { CEReactions }
    referrerPolicy: String; { CEReactions }
    contentDocument: JDocument;
    contentWindow: JWindowProxy;
    align: String; { CEReactions }
    scrolling: String; { CEReactions }
    frameBorder: String; { CEReactions }
    longDesc: String; { CEReactions }
    marginHeight: String; { CEReactions,TreatNullAs=EmptyString }
    marginWidth: String; { CEReactions,TreatNullAs=EmptyString }
    function getSVGDocument: JDocument;
  end;

  // HTMLConstructor
  JHTMLEmbedElement = class external 'HTMLEmbedElement' (JHTMLElement)
  public
    src: String; { CEReactions }
    &type: String; { CEReactions }
    width: String; { CEReactions }
    height: String; { CEReactions }
    align: String; { CEReactions }
    name: String; { CEReactions }
    function getSVGDocument: JDocument;
  end;

  // OverrideBuiltins,LegacyUnenumerableNamedProperties,HTMLConstructor
  JHTMLFormElement = partial class external 'HTMLFormElement' (JHTMLElement)
  public
    acceptCharset: String; { CEReactions }
    action: String; { CEReactions }
    autocomplete: String; { CEReactions }
    enctype: String; { CEReactions }
    encoding: String; { CEReactions }
    &method: String; { CEReactions }
    name: String; { CEReactions }
    noValidate: Boolean; { CEReactions }
    target: String; { CEReactions }
  end;

  JValidityState = class external 'ValidityState'
  public
    valueMissing: Boolean;
    typeMismatch: Boolean;
    patternMismatch: Boolean;
    tooLong: Boolean;
    tooShort: Boolean;
    rangeUnderflow: Boolean;
    rangeOverflow: Boolean;
    stepMismatch: Boolean;
    badInput: Boolean;
    customError: Boolean;
    valid: Boolean;
  end;

  // HTMLConstructor
  JHTMLObjectElement = class external 'HTMLObjectElement' (JHTMLElement)
  public
    data: String; { CEReactions }
    &type: String; { CEReactions }
    typeMustMatch: Boolean; { CEReactions }
    name: String; { CEReactions }
    useMap: String; { CEReactions }
    form: JHTMLFormElement;
    width: String; { CEReactions }
    height: String; { CEReactions }
    contentDocument: JDocument;
    contentWindow: JWindowProxy;
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    align: String; { CEReactions }
    archive: String; { CEReactions }
    code: String; { CEReactions }
    declare: Boolean; { CEReactions }
    hspace: Integer; { CEReactions }
    standby: String; { CEReactions }
    vspace: Integer; { CEReactions }
    codeBase: String; { CEReactions }
    codeType: String; { CEReactions }
    border: String; { CEReactions,TreatNullAs=EmptyString }
    function getSVGDocument: JDocument;
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
  end;

  // HTMLConstructor
  JHTMLParamElement = class external 'HTMLParamElement' (JHTMLElement)
  public
    name: String; { CEReactions }
    value: String; { CEReactions }
    &type: String; { CEReactions }
    valueType: String; { CEReactions }
  end;

  JHTMLMediaElement = partial class external 'HTMLMediaElement' (JHTMLElement)
  const
    NETWORK_EMPTY: Integer = 0;
    NETWORK_IDLE: Integer = 1;
    NETWORK_LOADING: Integer = 2;
    NETWORK_NO_SOURCE: Integer = 3;
    HAVE_NOTHING: Integer = 0;
    HAVE_METADATA: Integer = 1;
    HAVE_CURRENT_DATA: Integer = 2;
    HAVE_FUTURE_DATA: Integer = 3;
    HAVE_ENOUGH_DATA: Integer = 4;
  public
    currentSrc: String;
    crossOrigin: String; { CEReactions }
    networkState: Integer;
    preload: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLVideoElement = class external 'HTMLVideoElement' (JHTMLMediaElement)
  public
    width: Integer; { CEReactions }
    height: Integer; { CEReactions }
    videoWidth: Integer;
    videoHeight: Integer;
    poster: String; { CEReactions }
    playsInline: Boolean; { CEReactions }
  end;

  // HTMLConstructor,NamedConstructor=Audio( optional DOMString src)
  JHTMLAudioElement = class external 'HTMLAudioElement' (JHTMLMediaElement)
  end;

  JTextTrack = partial class external 'TextTrack' (JEventTarget);

  // HTMLConstructor
  JHTMLTrackElement = class external 'HTMLTrackElement' (JHTMLElement)
  const
    NONE: Integer = 0;
    LOADING: Integer = 1;
    LOADED: Integer = 2;
    ERROR: Integer = 3;
  public
    kind: String; { CEReactions }
    src: String; { CEReactions }
    srclang: String; { CEReactions }
    label: String; { CEReactions }
    default: Boolean; { CEReactions }
    readyState: Integer;
    track: JTextTrack;
  end;

  JCanPlayTypeResult = String;
  JCanPlayTypeResultHelper = strict helper for JCanPlayTypeResult
    const Maybe = 'maybe';
    const Probably = 'probably';
  end;

  JTextTrackMode = String;
  JTextTrackModeHelper = strict helper for JTextTrackMode
    const Disabled = 'disaled';
    const Hidden = 'hidden';
    const Showing = 'showing';
  end;

  JTextTrackKind = String;
  JTextTrackKindHelper = strict helper for JTextTrackMode
    const Subtitles = 'subtitles';
    const Captions = 'captions';
    const Descriptions = 'descriptions';
    const Chapters = 'chapters';
    const Metadata = 'metadata';
  end;

  TMediaProvider = Variant; // TODO

  JMediaError = class external 'MediaError'
  const
    MEDIA_ERR_ABORTED: Integer = 1;
    MEDIA_ERR_NETWORK: Integer = 2;
    MEDIA_ERR_DECODE: Integer = 3;
    MEDIA_ERR_SRC_NOT_SUPPORTED: Integer = 4;
  public
    code: Integer;
  end;

  JTimeRanges = class external 'TimeRanges'
  public
    length: Integer;
    function start(&index: Integer): Float;
    function &end(&index: Integer): Float;
  end;

  JHTMLMediaElement = partial class external 'HTMLMediaElement' (JHTMLElement)
  public
    error: JMediaError;
    src: String; { CEReactions }
    srcObject: TMediaProvider;
    buffered: JTimeRanges;
    readyState: Integer;
    seeking: Boolean;
    currentTime: Float;
    duration: Float;
    paused: Boolean;
    defaultPlaybackRate: Float;
    playbackRate: Float;
    played: JTimeRanges;
    seekable: JTimeRanges;
    ended: Boolean;
    autoplay: Boolean; { CEReactions }
    loop: Boolean; { CEReactions }
    controls: Boolean; { CEReactions }
    volume: Float;
    muted: Boolean;
    defaultMuted: Boolean; { CEReactions }
    procedure load;
    function canPlayType(&type: String): JCanPlayTypeResult;
    procedure fastSeek(time: Float);
    function getStartDate: Variant;
    procedure play;
    procedure pause;
    function addTextTrack(kind: JTextTrackKind): JTextTrack; overload;
    function addTextTrack(kind: JTextTrackKind; label: String): JTextTrack; overload;
    function addTextTrack(kind: JTextTrackKind; label, language: String): JTextTrack; overload;
  end;

  JEventHandlerNonNull = function(event: JEvent): Variant;
  TEventHandler = JEventHandlerNonNull;

  JOnErrorEventHandlerNonNull = function(event: Variant; source: String; lineno, colno: Integer; error: Variant): Variant; // TODO
  TOnErrorEventHandler = JOnErrorEventHandlerNonNull;

  JOnBeforeUnloadEventHandlerNonNull = function(event: JEvent): String;
  TOnBeforeUnloadEventHandler = JOnBeforeUnloadEventHandlerNonNull;

  JAudioTrack = class external 'AudioTrack'
  public
    id: String;
    kind: String;
    label: String;
    language: String;
    enabled: Boolean;
  end;

  JAudioTrackList = class external 'AudioTrackList' (JEventTarget)
  private
    function GetItem(Index: Integer): JAudioTrack; external array;
  public
    length: Integer;
    onchange: TEventHandler;
    onaddtrack: TEventHandler;
    onremovetrack: TEventHandler;
    function getTrackById(id: String): JAudioTrack;

    property Items[Index: Integer]: JAudioTrack read GetItem; default;
  end;

  JVideoTrack = class external 'VideoTrack'
  public
    id: String;
    kind: String;
    label: String;
    language: String;
    selected: Boolean;
  end;

  JVideoTrackList = class external 'VideoTrackList' (JEventTarget)
  private
    function GetItem(Index: Integer): JVideoTrack; external array;
  public
    length: Integer;
    selectedIndex: Integer;
    onchange: TEventHandler;
    onaddtrack: TEventHandler;
    onremovetrack: TEventHandler;
    function getTrackById(id: String): JVideoTrack;

    property Items[Index: Integer]: JVideoTrack read GetItem; default;
  end;

  JTextTrackList = class external 'TextTrackList' (JEventTarget)
  private
    function GetItem(Index: Integer): JVideoTrack; external array;
  public
    length: Integer;
    onchange: TEventHandler;
    onaddtrack: TEventHandler;
    onremovetrack: TEventHandler;
    property Items[Index: Integer]: JVideoTrack read GetItem; default;
  end;

  JTextTrackCue = partial class external 'TextTrackCue' (JEventTarget);

  JTextTrackCueList = class external 'TextTrackCueList'
  private
    function GetItem(Index: Integer): JTextTrackCue; external array;
  public
    length: Integer;
    function getCueById(id: String): JTextTrackCue;

    property Item[Index: Integer]: JTextTrackCue read GetItem;
  end;

  JTextTrack = partial class external 'TextTrack' (JEventTarget)
  public
    kind: JTextTrackKind;
    label: String;
    language: String;
    id: String;
    inBandMetadataTrackDispatchType: String;
    mode: JTextTrackMode;
    cues: JTextTrackCueList;
    activeCues: JTextTrackCueList;
    oncuechange: TEventHandler;
    procedure addCue(cue: JTextTrackCue);
    procedure removeCue(cue: JTextTrackCue);
  end;

  JTextTrackCue = partial class external 'TextTrackCue' (JEventTarget)
  public
    track: JTextTrack;
    id: String;
    startTime: Float;
    endTime: Float;
    pauseOnExit: Boolean;
    onenter: TEventHandler;
    onexit: TEventHandler;
  end;

  JTrackEventInit = class external 'TrackEventInit' (JEventInit)
  public
    track: Variant;
    trackAsAudioTrack: JAudioTrack; external 'track';
    trackAsVideoTrack: JVideoTrack; external 'track';
    trackAsTextTrack: JTextTrack; external 'track';
  end;

  JTrackEvent = class external 'TrackEvent' (JEvent)
  public
    track: Variant;
    trackAsAudioTrack: JAudioTrack; external 'track';
    trackAsVideoTrack: JVideoTrack; external 'track';
    trackAsTextTrack: JTextTrack; external 'track';
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JTrackEventInit); overload;
  end;

  JHTMLMediaElement = partial class external 'HTMLMediaElement' (JHTMLElement)
  public
    audioTracks: JAudioTrackList; { SameObject }
    videoTracks: JVideoTrackList; { SameObject }
    textTracks: JTextTrackList; { SameObject }
  end;

  // HTMLConstructor
  JHTMLMapElement = class external 'HTMLMapElement' (JHTMLElement)
  public
    name: String; { CEReactions }
    areas: JHTMLCollection; { SameObject }
  end;

  // HTMLConstructor
  JHTMLAreaElement = class external 'HTMLAreaElement' (JHTMLElement)
  public
    alt: String; { CEReactions }
    coords: String; { CEReactions }
    shape: String; { CEReactions }
    target: String; { CEReactions }
    download: String; { CEReactions }
    ping: String; { CEReactions }
    rel: String; { CEReactions }
    relList: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    referrerPolicy: String; { CEReactions }
    noHref: Boolean; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTableCaptionElement = class external 'HTMLTableCaptionElement' (JHTMLElement)
  public
    align: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTableColElement = class external 'HTMLTableColElement' (JHTMLElement)
  public
    span: Integer; { CEReactions }
    align: String; { CEReactions }
    ch: String; { CEReactions }
    chOff: String; { CEReactions }
    vAlign: String; { CEReactions }
    width: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTableSectionElement = class external 'HTMLTableSectionElement' (JHTMLElement)
  public
    rows: JHTMLCollection; { SameObject }
    align: String; { CEReactions }
    ch: String; { CEReactions }
    chOff: String; { CEReactions }
    vAlign: String; { CEReactions }
    function insertRow(&index: Integer = -1): JHTMLElement;
    procedure deleteRow(&index: Integer); { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTableRowElement = class external 'HTMLTableRowElement' (JHTMLElement)
  public
    rowIndex: Integer;
    sectionRowIndex: Integer;
    cells: JHTMLCollection; { SameObject }
    align: String; { CEReactions }
    ch: String; { CEReactions }
    chOff: String; { CEReactions }
    vAlign: String; { CEReactions }
    bgColor: String; { CEReactions,TreatNullAs=EmptyString }
    function insertCell(&index: Integer = -1): JHTMLElement;
    procedure deleteCell(&index: Integer); { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTableCellElement = class external 'HTMLTableCellElement' (JHTMLElement)
  public
    colSpan: Integer; { CEReactions }
    rowSpan: Integer; { CEReactions }
    headers: String; { CEReactions }
    cellIndex: Integer;
    scope: String; { CEReactions }
    abbr: String; { CEReactions }
    align: String; { CEReactions }
    axis: String; { CEReactions }
    height: String; { CEReactions }
    width: String; { CEReactions }
    ch: String; { CEReactions }
    chOff: String; { CEReactions }
    noWrap: Boolean; { CEReactions }
    vAlign: String; { CEReactions }
    bgColor: String; { CEReactions,TreatNullAs=EmptyString }
  end;

  // HTMLConstructor
  JHTMLTableElement = class external 'HTMLTableElement' (JHTMLElement)
  public
    caption: JHTMLTableCaptionElement; { CEReactions }
    tHead: JHTMLTableSectionElement; { CEReactions }
    tFoot: JHTMLTableSectionElement; { CEReactions }
    tBodies: JHTMLCollection; { SameObject }
    rows: JHTMLCollection; { SameObject }
    align: String; { CEReactions }
    border: String; { CEReactions }
    frame: String; { CEReactions }
    rules: String; { CEReactions }
    summary: String; { CEReactions }
    width: String; { CEReactions }
    bgColor: String; { CEReactions,TreatNullAs=EmptyString }
    cellPadding: String; { CEReactions,TreatNullAs=EmptyString }
    cellSpacing: String; { CEReactions,TreatNullAs=EmptyString }
    function createCaption: JHTMLTableCaptionElement;
    procedure deleteCaption; { CEReactions }
    function createTHead: JHTMLTableSectionElement;
    procedure deleteTHead; { CEReactions }
    function createTFoot: JHTMLTableSectionElement;
    procedure deleteTFoot; { CEReactions }
    function createTBody: JHTMLTableSectionElement;
    function insertRow(&index: Integer = -1): JHTMLTableRowElement;
    procedure deleteRow(&index: Integer); { CEReactions }
  end;

  // OverrideBuiltins,LegacyUnenumerableNamedProperties,HTMLConstructor
  JHTMLFormElement = partial class external 'HTMLFormElement' (JHTMLElement)
  private
    function GetElement(Index: Integer): JElement; external array;
// TODO    function GetNamedElement(name: String): Union; external array;
  public
    elements: JHTMLFormControlsCollection; { SameObject }
    length: Integer;
    procedure submit;
    procedure reset; { CEReactions }
    function checkValidity: Boolean;
    function reportValidity: Boolean;

    property Element[index : Integer] : JElement read GetElement; default;
  end;

  // HTMLConstructor
  JHTMLLabelElement = class external 'HTMLLabelElement' (JHTMLElement)
  public
    form: JHTMLFormElement;
    htmlFor: String; { CEReactions }
    control: JHTMLElement;
  end;

  JSelectionMode = String;
  JSelectionModeHelper = strict helper for JSelectionMode
    const Select = 'select';
    const Start = 'start';
    const &End = 'end';
    const Preserve = 'preserve';
  end;

  // HTMLConstructor
  JHTMLInputElement = class external 'HTMLInputElement' (JHTMLElement)
  public
    accept: String; { CEReactions }
    alt: String; { CEReactions }
    autocomplete: String; { CEReactions }
    autofocus: Boolean; { CEReactions }
    defaultChecked: Boolean; { CEReactions }
    checked: Boolean;
    dirName: String; { CEReactions }
    disabled: Boolean; { CEReactions }
    form: JHTMLFormElement;
    formAction: String; { CEReactions }
    formEnctype: String; { CEReactions }
    formMethod: String; { CEReactions }
    formNoValidate: Boolean; { CEReactions }
    formTarget: String; { CEReactions }
    height: Integer; { CEReactions }
    indeterminate: Boolean;
    inputMode: String; { CEReactions }
    list: JHTMLElement;
    max: String; { CEReactions }
    maxLength: Integer; { CEReactions }
    min: String; { CEReactions }
    minLength: Integer; { CEReactions }
    multiple: Boolean; { CEReactions }
    name: String; { CEReactions }
    pattern: String; { CEReactions }
    placeholder: String; { CEReactions }
    readOnly: Boolean; { CEReactions }
    required: Boolean; { CEReactions }
    size: Integer; { CEReactions }
    src: String; { CEReactions }
    step: String; { CEReactions }
    &type: String; { CEReactions }
    defaultValue: String; { CEReactions }
    value: String; { CEReactions,TreatNullAs=EmptyString }
    valueAsDate: Variant;
    valueAsNumber: Float;
    width: Integer; { CEReactions }
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    labels: JNodeList; { SameObject }
    selectionStart: Integer;
    selectionEnd: Integer;
    selectionDirection: String;
    align: String; { CEReactions }
    useMap: String; { CEReactions }
    procedure stepUp(n: Integer = 1);
    procedure stepDown(n: Integer = 1);
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
    procedure select;
    procedure setRangeText(replacement: String); overload;
    procedure setRangeText(replacement: String; start: Integer; &end: Integer; selectionMode: JSelectionMode = 'preserve'); overload;
    procedure setSelectionRange(start: Integer; &end: Integer); overload;
    procedure setSelectionRange(start: Integer; &end: Integer; direction: String); overload;
  end;

  // HTMLConstructor
  JHTMLMenuElement = class external 'HTMLMenuElement' (JHTMLElement)
  public
    &type: String; { CEReactions }
    label: String; { CEReactions }
    compact: Boolean; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLButtonElement = class external 'HTMLButtonElement' (JHTMLElement)
  public
    autofocus: Boolean; { CEReactions }
    disabled: Boolean; { CEReactions }
    form: JHTMLFormElement;
    formAction: String; { CEReactions }
    formEnctype: String; { CEReactions }
    formMethod: String; { CEReactions }
    formNoValidate: Boolean; { CEReactions }
    formTarget: String; { CEReactions }
    name: String; { CEReactions }
    &type: String; { CEReactions }
    value: String; { CEReactions }
    menu: JHTMLMenuElement; { CEReactions }
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    labels: JNodeList; { SameObject }
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
  end;

  // HTMLConstructor
  JHTMLSelectElement = class external 'HTMLSelectElement' (JHTMLElement)
  private
    procedure SetItem(Index: Integer; option: JHTMLOptionElement);
  public
    autocomplete: String; { CEReactions }
    autofocus: Boolean; { CEReactions }
    disabled: Boolean; { CEReactions }
    form: JHTMLFormElement;
    multiple: Boolean; { CEReactions }
    name: String; { CEReactions }
    required: Boolean; { CEReactions }
    size: Integer; { CEReactions }
    &type: String;
    options: JHTMLOptionsCollection; { SameObject }
    length: Integer; { CEReactions }
    selectedOptions: JHTMLCollection; { SameObject }
    selectedIndex: Integer;
    value: String;
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    labels: JNodeList; { SameObject }
    function item(&index: Integer): JElement;
    function namedItem(&name: String): JHTMLOptionElement;
    procedure add(element: JHTMLObjectElement); overload;
    procedure add(element: JHTMLObjectElement; before: JHTMLElement); overload;
    procedure add(element: JHTMLObjectElement; before: Integer); overload;
    procedure add(element: JHTMLOptGroupElement); overload;
    procedure add(element: JHTMLOptGroupElement; before: JHTMLElement); overload;
    procedure add(element: JHTMLOptGroupElement; before: Integer); overload;
    procedure remove; overload;
    procedure remove(&index: Integer); overload;
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);

    property Items[Index: Integer]: JHTMLOptionElement write SetItem; default;
  end;

  // HTMLConstructor
  JHTMLDataListElement = class external 'HTMLDataListElement' (JHTMLElement)
  public
    options: JHTMLCollection; { SameObject }
  end;

  // HTMLConstructor,NamedConstructor=Option( optional DOMString text , optional DOMString value , optional boolean defaultSelected = false , optional boolean selected = false)
  JHTMLOptionElement = partial class external 'HTMLOptionElement' (JHTMLElement)
  public
    form: JHTMLFormElement;
  end;

  // HTMLConstructor
  JHTMLTextAreaElement = class external 'HTMLTextAreaElement' (JHTMLElement)
  public
    autocomplete: String; { CEReactions }
    autofocus: Boolean; { CEReactions }
    cols: Integer; { CEReactions }
    dirName: String; { CEReactions }
    disabled: Boolean; { CEReactions }
    form: JHTMLFormElement;
    inputMode: String; { CEReactions }
    maxLength: Integer; { CEReactions }
    minLength: Integer; { CEReactions }
    name: String; { CEReactions }
    placeholder: String; { CEReactions }
    readOnly: Boolean; { CEReactions }
    required: Boolean; { CEReactions }
    rows: Integer; { CEReactions }
    wrap: String; { CEReactions }
    &type: String;
    defaultValue: String; { CEReactions }
    value: String; { CEReactions,TreatNullAs=EmptyString }
    textLength: Integer;
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    labels: JNodeList; { SameObject }
    selectionStart: Integer;
    selectionEnd: Integer;
    selectionDirection: String;
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
    procedure select;
    procedure setRangeText(replacement: String); overload;
    procedure setRangeText(replacement: String; start: Integer; &end: Integer; selectionMode: JSelectionMode = 'preserve'); overload;
    procedure setSelectionRange(start: Integer; &end: Integer); overload;
    procedure setSelectionRange(start: Integer; &end: Integer; direction: String); overload;
  end;

  // HTMLConstructor
  JHTMLKeygenElement = class external 'HTMLKeygenElement' (JHTMLElement)
  public
    autofocus: Boolean; { CEReactions }
    challenge: String; { CEReactions }
    disabled: Boolean; { CEReactions }
    form: JHTMLFormElement;
    keytype: String; { CEReactions }
    name: String; { CEReactions }
    &type: String;
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    labels: JNodeList; { SameObject }
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
  end;

  // HTMLConstructor
  JHTMLOutputElement = class external 'HTMLOutputElement' (JHTMLElement)
  public
    htmlFor: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    form: JHTMLFormElement;
    name: String; { CEReactions }
    &type: String;
    defaultValue: String; { CEReactions }
    value: String; { CEReactions }
    willValidate: Boolean;
    validity: JValidityState;
    validationMessage: String;
    labels: JNodeList; { SameObject }
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
  end;

  // HTMLConstructor
  JHTMLProgressElement = class external 'HTMLProgressElement' (JHTMLElement)
  public
    value: Float; { CEReactions }
    max: Float; { CEReactions }
    position: Float;
    labels: JNodeList; { SameObject }
  end;

  // HTMLConstructor
  JHTMLMeterElement = class external 'HTMLMeterElement' (JHTMLElement)
  public
    value: Float; { CEReactions }
    min: Float; { CEReactions }
    max: Float; { CEReactions }
    low: Float; { CEReactions }
    high: Float; { CEReactions }
    optimum: Float; { CEReactions }
    labels: JNodeList; { SameObject }
  end;

  // HTMLConstructor
  JHTMLFieldSetElement = class external 'HTMLFieldSetElement' (JHTMLElement)
  public
    disabled: Boolean; { CEReactions }
    form: JHTMLFormElement;
    name: String; { CEReactions }
    &type: String;
    elements: JHTMLCollection; { SameObject }
    willValidate: Boolean;
    validity: JValidityState; { SameObject }
    validationMessage: String;
    function checkValidity: Boolean;
    function reportValidity: Boolean;
    procedure setCustomValidity(error: String);
  end;

  // HTMLConstructor
  JHTMLLegendElement = class external 'HTMLLegendElement' (JHTMLElement)
  public
    form: JHTMLFormElement;
    align: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLDetailsElement = class external 'HTMLDetailsElement' (JHTMLElement)
  public
    open: Boolean; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLElement = partial class external 'HTMLElement' (JElement)
  public
    dataset: JDOMStringMap; { SameObject }
    dropzone: JDOMTokenList; { CEReactions,SameObject,PutForwards=value }
    contextMenu: JHTMLMenuElement; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLMenuItemElement = class external 'HTMLMenuItemElement' (JHTMLElement)
  public
    &type: String; { CEReactions }
    label: String; { CEReactions }
    icon: String; { CEReactions }
    disabled: Boolean; { CEReactions }
    checked: Boolean; { CEReactions }
    radiogroup: String; { CEReactions }
    default: Boolean; { CEReactions }
  end;

  JRelatedEventInit = class external 'RelatedEventInit' (JEventInit)
  public
    relatedTarget: JEventTarget;
  end;

  JRelatedEvent = class external 'RelatedEvent' (JEvent)
  public
    relatedTarget: JEventTarget;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JRelatedEventInit); overload;
  end;

  // HTMLConstructor
  JHTMLDialogElement = class external 'HTMLDialogElement' (JHTMLElement)
  public
    open: Boolean; { CEReactions }
    returnValue: String;
    procedure show; overload;
    procedure show(anchor: JElement); overload;
// TODO    procedure show(anchor: JMouseEvent); overload;
    procedure showModal; overload;
    procedure showModal(anchor: JElement); overload;
// TODO    procedure showModal(anchor: JMouseEvent); overload;
    procedure close; overload; { CEReactions }
    procedure close(returnValue: String); overload; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLScriptElement = class external 'HTMLScriptElement' (JHTMLElement)
  public
    src: String; { CEReactions }
    &type: String; { CEReactions }
    charset: String; { CEReactions }
    async: Boolean; { CEReactions }
    defer: Boolean; { CEReactions }
    crossOrigin: String; { CEReactions }
    text: String; { CEReactions }
    nonce: String; { CEReactions }
    integrity: String; { CEReactions }
    event: String; { CEReactions }
    htmlFor: String; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLTemplateElement = class external 'HTMLTemplateElement' (JHTMLElement)
  public
    content: JDocumentFragment;
  end;

  JAssignedNodesOptions = class external 'AssignedNodesOptions'
  public
    flatten: Boolean;
  end;

  // HTMLConstructor
  JHTMLSlotElement = class external 'HTMLSlotElement' (JHTMLElement)
  public
    name: String; { CEReactions }
    function assignedNodes: array of JNode; overload;
    function assignedNodes(options: JAssignedNodesOptions): array of JNode; overload;
  end;

  // TODO
  TRenderingContext = Variant;
  THTMLOrSVGImageElement = Variant;
  TCanvasImageSource = Variant;

  // HTMLConstructor
  JHTMLCanvasElement = class external 'HTMLCanvasElement' (JHTMLElement)
  public
    width: Integer; { CEReactions }
    height: Integer; { CEReactions }
    function getContext(contextId: String; arguments: Variant): TRenderingContext;
    function toDataURL: String; overload;
    function toDataURL(&type: String): String; overload;
    function toDataURL(&type: String; quality: Variant): String; overload;
  end;

  JCanvasFillRule = String;
  JCanvasFillRuleHelper = strict helper for JCanvasFillRule
   const NonZero = 'nonzero';
   const EvenOdd = 'evenodd';
  end;

  JCanvasRenderingContext2DSettings = class external 'CanvasRenderingContext2DSettings'
  public
    alpha: Boolean;
  end;

  JImageSmoothingQuality = String;
  JImageSmoothingQualityHelper = strict helper for JImageSmoothingQuality
    const Lo = 'Low';
    const Medium = 'Medium';
    const Hi = 'High';
  end;

  JCanvasRenderingContext2D = class external 'CanvasRenderingContext2D'
  public
    canvas: JHTMLCanvasElement;
  end;

  // NoInterfaceObject
  JCanvasState = class external 'CanvasState'
  public
    procedure save;
    procedure restore;
  end;

  // NoInterfaceObject
  JCanvasTransform = class external 'CanvasTransform'
  public
    procedure scale(x: Float; y: Float);
    procedure rotate(angle: Float);
    procedure translate(x: Float; y: Float);
    procedure transform(a: Float; b: Float; c: Float; d: Float; e: Float; f: Float);
    function getTransform: JDOMMatrix; { NewObject }
    procedure setTransform(a: Float; b: Float; c: Float; d: Float; e: Float; f: Float);
    procedure setTransform; overload;
// TODO    procedure setTransform(transform: JDOMMatrixInit); overload;
    procedure resetTransform;
  end;

  // NoInterfaceObject
  JCanvasCompositing = class external 'CanvasCompositing'
  public
    globalAlpha: Float;
    globalCompositeOperation: String;
  end;

  // NoInterfaceObject
  JCanvasImageSmoothing = class external 'CanvasImageSmoothing'
  public
    imageSmoothingEnabled: Boolean;
    imageSmoothingQuality: JImageSmoothingQuality;
  end;

  JCanvasGradient = class external 'CanvasGradient'
  public
    procedure addColorStop(offset: Float; color: String);
  end;

  JCanvasPattern = class external 'CanvasPattern'
  public
    procedure setTransform; overload;
// TODO    procedure setTransform(transform: JDOMMatrixInit); overload;
  end;

  // NoInterfaceObject
  JCanvasFillStrokeStyles = class external 'CanvasFillStrokeStyles'
  public
    strokeStyle: Variant;
    fillStyle: Variant;
    function createLinearGradient(x0: Float; y0: Float; x1: Float; y1: Float): JCanvasGradient;
    function createRadialGradient(x0: Float; y0: Float; r0: Float; x1: Float; y1: Float; r1: Float): JCanvasGradient;
    function createPattern(image: TCanvasImageSource; repetition: String { TreatNullAs=EmptyString } ): JCanvasPattern;
  end;

  // NoInterfaceObject
  JCanvasShadowStyles = class external 'CanvasShadowStyles'
  public
    shadowOffsetX: Float;
    shadowOffsetY: Float;
    shadowBlur: Float;
    shadowColor: String;
  end;

  // NoInterfaceObject
  JCanvasFilters = class external 'CanvasFilters'
  public
    filter: String;
  end;

  // NoInterfaceObject
  JCanvasRect = class external 'CanvasRect'
  public
    procedure clearRect(x: Float; y: Float; w: Float; h: Float);
    procedure fillRect(x: Float; y: Float; w: Float; h: Float);
    procedure strokeRect(x: Float; y: Float; w: Float; h: Float);
  end;

  // Exposed = (Window, Worker)
  JPath2D = class external 'Path2D'
  public
    procedure addPath(path: JPath2D); overload;
// TODO    procedure addPath(path: JPath2D; transform: JDOMMatrixInit); overload;
    constructor Create; overload;
    constructor Create(path: JPath2D); overload;
    constructor Create(paths: array of JPath2D); overload;
    constructor Create(paths: array of JPath2D; fillRule: JCanvasFillRule); overload;
    constructor Create(d: String); overload;
  end;

  // NoInterfaceObject
  JCanvasDrawPath = class external 'CanvasDrawPath'
  public
    procedure beginPath;
    procedure fill; overload;
    procedure fill(fillRule: JCanvasFillRule); overload;
    procedure fill(path: JPath2D; fillRule: JCanvasFillRule); overload;
    procedure stroke; overload;
    procedure stroke(path: JPath2D); overload;
    procedure clip; overload;
    procedure clip(fillRule: JCanvasFillRule); overload;
    procedure clip(path: JPath2D; fillRule: JCanvasFillRule); overload;
    procedure resetClip;
    function isPointInPath(x, y: Float): Boolean; overload;
    function isPointInPath(x, y: Float; fillRule: JCanvasFillRule): Boolean; overload;
    function isPointInPath(path: JPath2D; x, y: Float): Boolean; overload;
    function isPointInPath(path: JPath2D; x, y: Float; fillRule: JCanvasFillRule): Boolean; overload;
    function isPointInStroke(x, y: Float): Boolean; overload;
    function isPointInStroke(path: JPath2D; x, y: Float): Boolean; overload;
  end;

  JCanvasLineCap = String;
  JCanvasLineCapHelper = strict helper for JCanvasLineCap
    const Butt = 'butt';
    const Round = 'round';
    const Square = 'square';
  end;

  JCanvasLineJoin = String;
  JCanvasLineJoinHelper = strict helper for JCanvasLineJoin
    const Round = 'round';
    const Bevel = 'bevel';
    const Miter = 'miter';
  end;

  JCanvasTextAlign = String;
  JCanvasTextAlignHelper = strict helper for JCanvasTextAlign
    const Start = 'start';
    const &End = 'end';
    const Left = 'left';
    const Right = 'right';
    const Center = 'center';
  end;

  JCanvasTextBaseline = String;
  JCanvasTextBaselineHelper = strict helper for JCanvasTextBaseline
    const Top = 'top';
    const Hanging = 'hanging';
    const Middle = 'middle';
    const Alphabetic = 'alphabetic';
    const Ideographic = 'ideographic';
    const Bottom = 'bottom';
  end;

  JCanvasDirection = String;
  JCanvasDirectionHelper = strict helper for JCanvasDirection
    const Ltr = 'ltr';
    const Rtl = 'rtl';
    const Inherit = 'inherit';
  end;

  // NoInterfaceObject
  JCanvasUserInterface = class external 'CanvasUserInterface'
  public
    procedure drawFocusIfNeeded(element: JElement); overload;
    procedure drawFocusIfNeeded(path: JPath2D; element: JElement); overload;
    procedure scrollPathIntoView; overload;
    procedure scrollPathIntoView(path: JPath2D); overload;
  end;

  JTextMetrics = class external 'TextMetrics'
  public
    width: Float;
    actualBoundingBoxLeft: Float;
    actualBoundingBoxRight: Float;
    fontBoundingBoxAscent: Float;
    fontBoundingBoxDescent: Float;
    actualBoundingBoxAscent: Float;
    actualBoundingBoxDescent: Float;
    emHeightAscent: Float;
    emHeightDescent: Float;
    hangingBaseline: Float;
    alphabeticBaseline: Float;
    ideographicBaseline: Float;
  end;

  // NoInterfaceObject
  JCanvasText = class external 'CanvasText'
  public
    procedure fillText(text: String; x, y: Float); overload;
    procedure fillText(text: String; x, y, maxWidth: Float); overload;
    procedure strokeText(text: String; x, y: Float); overload;
    procedure strokeText(text: String; x, y, maxWidth: Float); overload;
    function measureText(text: String): JTextMetrics;
  end;

  // NoInterfaceObject
  JCanvasDrawImage = class external 'CanvasDrawImage'
  public
    procedure drawImage(image: TCanvasImageSource; dx, dy: Float); overload;
    procedure drawImage(image: TCanvasImageSource; dx, dy, dw, dh: Float); overload;
    procedure drawImage(image: TCanvasImageSource; sx, sy, sw, sh, dx, dy, dw, dh: Float); overload;
  end;

  // Exposed = (Window, Worker)
  JImageData = class external 'ImageData'
  public
    width: Integer;
    height: Integer;
    data: JUint8ClampedArray;
    constructor Create(sw, sh: Integer); overload;
    constructor Create(data: JUint8ClampedArray; sw: Integer); overload;
    constructor Create(data: JUint8ClampedArray; sw, sh: Integer); overload;
  end;

  // NoInterfaceObject
  JCanvasImageData = class external 'CanvasImageData'
  public
    function createImageData(sw, sh: Float): JImageData; overload;
    function createImageData(imagedata: JImageData): JImageData; overload;
    function getImageData(sx, sy, sw, sh: Float): JImageData;
    procedure putImageData(imagedata: JImageData; dx, dy: Float); overload;
    procedure putImageData(imagedata: JImageData; dx, dy, dirtyX, dirtyY,
      dirtyWidth, dirtyHeight: Float); overload;
  end;

  // NoInterfaceObject
  JCanvasPathDrawingStyles = class external 'CanvasPathDrawingStyles'
  public
    lineWidth: Float;
    lineCap: JCanvasLineCap;
    lineJoin: JCanvasLineJoin;
    miterLimit: Float;
    lineDashOffset: Float;
    procedure setLineDash(segments: array of Float);
    function getLineDash: array of Float;
  end;

  // NoInterfaceObject
  JCanvasTextDrawingStyles = class external 'CanvasTextDrawingStyles'
  public
    font: String;
    textAlign: JCanvasTextAlign;
    textBaseline: JCanvasTextBaseline;
    direction: JCanvasDirection;
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JCanvasPath = class external 'CanvasPath'
  public
    procedure closePath;
    procedure moveTo(x, y: Float);
    procedure lineTo(x, y: Float);
    procedure quadraticCurveTo(cpx, cpy, x, y: Float);
    procedure bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y: Float);
    procedure arcTo(x1, y1, x2, y2, radius: Float); overload;
    procedure arcTo(x1, y1, x2, y2, radiusX, radiusY, rotation: Float); overload;
    procedure rect(x, y, w, h: Float);
    procedure arc(x, y, radius, startAngle, endAngle: Float;
      anticlockwise: Boolean = False);
    procedure ellipse(x, y, radiusX, radiusY, rotation, startAngle,
      endAngle: Float; anticlockwise: Boolean = False);
  end;

  // Exposed=( Window , Worker)
  JImageBitmap = class external 'ImageBitmap'
  public
    width: Integer;
    height: Integer;
    procedure close;
  end;

  JImageBitmapRenderingContext = class external 'ImageBitmapRenderingContext'
  public
    canvas: JHTMLCanvasElement;
    procedure transferFromImageBitmap(bitmap: JImageBitmap);
  end;

  JImageBitmapRenderingContextSettings = class external 'ImageBitmapRenderingContextSettings'
  public
    alpha: Boolean;
  end;

  JElementDefinitionOptions = class external 'ElementDefinitionOptions'
  public
    extends: String;
  end;

  JCustomElementRegistry = class external 'CustomElementRegistry'
  public
    procedure define(&name: String; &constructor: procedure); overload; { CEReactions }
    procedure define(&name: String; &constructor: procedure; options: JElementDefinitionOptions); overload; { CEReactions }
    function get(&name: String): Variant;
    function whenDefined(&name: String): variant;
  end;

  // NoInterfaceObject
  JElementContentEditable = class external 'ElementContentEditable'
  public
    contentEditable: String; { CEReactions }
    isContentEditable: Boolean;
  end;

  TFunctionStringCallback = procedure(data: String);

  JDataTransferItem = class external 'DataTransferItem'
  public
    kind: String;
    &type: String;
    procedure getAsString(_callback: TFunctionStringCallback);
  end;

  JDataTransferItemList = class external 'DataTransferItemList'
  private
    function GetItem(Index: Integer): JDataTransferItem;
  public
    length: Integer;
    function add(data: String; &type: String): JDataTransferItem; overload;
    procedure remove(&index: Integer);
    procedure clear;

    property Items[Index: Integer]: JDataTransferItem read GetItem;
  end;

  JDataTransfer = class external 'DataTransfer'
  public
    dropEffect: String;
    effectAllowed: String;
    items: JDataTransferItemList; { SameObject }
    procedure setDragImage(image: JElement; x: Integer; y: Integer);
    function getData(format: String): String;
    procedure setData(format: String; data: String);
    procedure clearData; overload;
    procedure clearData(format: String); overload;
  end;

  JDragEventInit = class external 'DragEventInit' (JMouseEventInit)
  public
    dataTransfer: JDataTransfer;
  end;

  JDragEvent = class external 'DragEvent' (JMouseEvent)
  public
    dataTransfer: JDataTransfer;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JDragEventInit); overload;
  end;

  JLocation = class external 'Location'
  public
    origin: String; { Unforgeable }
    protocol: String; { Unforgeable }
    host: String; { Unforgeable }
    hostname: String; { Unforgeable }
    port: String; { Unforgeable }
    pathname: String; { Unforgeable }
    search: String; { Unforgeable }
    hash: String; { Unforgeable }
    procedure assign(url: String); { Unforgeable }
    procedure replace(url: String); { Unforgeable }
    procedure reload; { Unforgeable }
  end;

  JScrollRestoration = String;
  JScrollRestorationHelper = strict helper for JScrollRestoration
    const Auto = 'auto';
    const Manual = 'manual';
  end;

  JHistory = class external 'History'
  public
    length: Integer;
    scrollRestoration: JScrollRestoration;
    state: Variant;
    procedure go(delta: Integer = 0);
    procedure back;
    procedure forward;
    procedure pushState(data: Variant; title: String); overload;
    procedure pushState(data: Variant; title: String; url: String); overload;
    procedure replaceState(data: Variant; title: String); overload;
    procedure replaceState(data: Variant; title: String; url: String); overload;
  end;

  JBarProp = class external 'BarProp'
  public
    visible: Boolean;
  end;

  JPopStateEventInit = class external 'PopStateEventInit' (JEventInit)
  public
    state: Variant;
  end;

  JPopStateEvent = class external 'PopStateEvent' (JEvent)
  public
    state: Variant;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JPopStateEventInit); overload;
  end;

  JFrameRequestCallback = procedure(time: TDOMHighResTimeStamp);

  JHashChangeEventInit = class external 'HashChangeEventInit' (JEventInit)
  public
    oldURL: String;
    newURL: String;
  end;

  JHashChangeEvent = class external 'HashChangeEvent' (JEvent)
  public
    oldURL: String;
    newURL: String;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JHashChangeEventInit); overload;
  end;

  JPageTransitionEventInit = class external 'PageTransitionEventInit' (JEventInit)
  public
    persisted: Boolean;
  end;

  JPageTransitionEvent = class external 'PageTransitionEvent' (JEvent)
  public
    persisted: Boolean;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JPageTransitionEventInit); overload;
  end;

  JBeforeUnloadEvent = class external 'BeforeUnloadEvent' (JEvent)
  public
    returnValue: String;
  end;

  // Exposed = (Window, SharedWorker)
  JApplicationCache = partial class external 'ApplicationCache' (JEventTarget)
  const
    UNCACHED: Integer = 0;
    IDLE: Integer = 1;
    CHECKING: Integer = 2;
    DOWNLOADING: Integer = 3;
    UPDATEREADY: Integer = 4;
    OBSOLETE: Integer = 5;
  public
    status: Integer;
    onchecking: TEventHandler;
    onerror: TEventHandler;
    onnoupdate: TEventHandler;
    ondownloading: TEventHandler;
    onprogress: TEventHandler;
    onupdateready: TEventHandler;
    oncached: TEventHandler;
    onobsolete: TEventHandler;
    procedure update;
    procedure abort;
    procedure swapCache;
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JNavigatorOnLine = class external 'NavigatorOnLine'
  public
    onLine: Boolean;
  end;

  JErrorEventInit = class external 'ErrorEventInit' (JEventInit)
  public
    message: String;
    filename: String;
    lineno: Integer;
    colno: Integer;
    error: Variant;
  end;

  // Exposed = (Window, Worker)
  JErrorEvent = class external 'ErrorEvent' (JEvent)
  public
    message: String;
    filename: String;
    lineno: Integer;
    colno: Integer;
    error: Variant;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JErrorEventInit); overload;
  end;

  JPromiseRejectionEventInit = class external 'PromiseRejectionEventInit' (JEventInit)
  public
    promise: Variant;
    reason: Variant;
  end;

  // Exposed = (Window, Worker)
  JPromiseRejectionEvent = class external 'PromiseRejectionEvent' (JEvent)
  public
    promise: Variant;
    reason: Variant;
    constructor Create(&type: String; eventInitDict: JPromiseRejectionEventInit);
  end;

  // NoInterfaceObject
  JGlobalEventHandlers = class external 'GlobalEventHandlers'
  public
    onabort: TEventHandler;
    onblur: TEventHandler;
    oncancel: TEventHandler;
    oncanplay: TEventHandler;
    oncanplaythrough: TEventHandler;
    onchange: TEventHandler;
    onclick: TEventHandler;
    onclose: TEventHandler;
    oncontextmenu: TEventHandler;
    oncuechange: TEventHandler;
    ondblclick: TEventHandler;
    ondrag: TEventHandler;
    ondragend: TEventHandler;
    ondragenter: TEventHandler;
    ondragexit: TEventHandler;
    ondragleave: TEventHandler;
    ondragover: TEventHandler;
    ondragstart: TEventHandler;
    ondrop: TEventHandler;
    ondurationchange: TEventHandler;
    onemptied: TEventHandler;
    onended: TEventHandler;
    onerror: TOnErrorEventHandler;
    onfocus: TEventHandler;
    oninput: TEventHandler;
    oninvalid: TEventHandler;
    onkeydown: TEventHandler;
    onkeypress: TEventHandler;
    onkeyup: TEventHandler;
    onload: TEventHandler;
    onloadeddata: TEventHandler;
    onloadedmetadata: TEventHandler;
    onloadend: TEventHandler;
    onloadstart: TEventHandler;
    onmousedown: TEventHandler;
    onmouseenter: TEventHandler; { LenientThis }
    onmouseleave: TEventHandler; { LenientThis }
    onmousemove: TEventHandler;
    onmouseout: TEventHandler;
    onmouseover: TEventHandler;
    onmouseup: TEventHandler;
    onwheel: TEventHandler;
    onpause: TEventHandler;
    onplay: TEventHandler;
    onplaying: TEventHandler;
    onprogress: TEventHandler;
    onratechange: TEventHandler;
    onreset: TEventHandler;
    onresize: TEventHandler;
    onscroll: TEventHandler;
    onseeked: TEventHandler;
    onseeking: TEventHandler;
    onselect: TEventHandler;
    onshow: TEventHandler;
    onstalled: TEventHandler;
    onsubmit: TEventHandler;
    onsuspend: TEventHandler;
    ontimeupdate: TEventHandler;
    ontoggle: TEventHandler;
    onvolumechange: TEventHandler;
    onwaiting: TEventHandler;
  end;

  // NoInterfaceObject
  JWindowEventHandlers = class external 'WindowEventHandlers'
  public
    onafterprint: TEventHandler;
    onbeforeprint: TEventHandler;
    onbeforeunload: TOnBeforeUnloadEventHandler;
    onhashchange: TEventHandler;
    onlanguagechange: TEventHandler;
    onmessage: TEventHandler;
    onoffline: TEventHandler;
    ononline: TEventHandler;
    onpagehide: TEventHandler;
    onpageshow: TEventHandler;
    onpopstate: TEventHandler;
    onrejectionhandled: TEventHandler;
    onstorage: TEventHandler;
    onunhandledrejection: TEventHandler;
    onunload: TEventHandler;
  end;

  // NoInterfaceObject
  JDocumentAndElementEventHandlers = class external 'DocumentAndElementEventHandlers'
  public
    oncopy: TEventHandler;
    oncut: TEventHandler;
    onpaste: TEventHandler;
  end;

  TTimerHandler = Variant;  // TODO

  JImageOrientation = String;
  JImageOrientationHelper = strict helper for JImageOrientation
    const None = 'none';
    const FlipY = 'flipy';
  end;

  JPremultiplyAlpha = String;
  JPremultiplyAlphaHelper = strict helper for JPremultiplyAlpha
    const None = 'none';
    const Premultiply = 'premultiply';
    const Default = 'default';
  end;

  JColorSpaceConversion = String;
  JColorSpaceConversionHelper = strict helper for JColorSpaceConversion
    const None = 'none';
    const Default = 'default';
  end;

  JResizeQuality = String;
  JResizeQualityHelper = strict helper for JResizeQuality
    const Pixelated = 'pixelated';
    const Lo = 'low';
    const Medium = 'medium';
    const Hi = 'high';
  end;


  JImageBitmapOptions = class external 'ImageBitmapOptions'
  public
    imageOrientation: JImageOrientation;
    premultiplyAlpha: JPremultiplyAlpha;
    colorSpaceConversion: JColorSpaceConversion;
    resizeWidth: Integer; { EnforceRange }
    resizeHeight: Integer; { EnforceRange }
    resizeQuality: JResizeQuality;
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JWindowOrWorkerGlobalScope = partial class external 'WindowOrWorkerGlobalScope'
  public
    origin: String; { Replaceable }
    function btoa(data: String): String;
    function atob(data: String): String;
    function setTimeout(handler: TTimerHandler; timeout: Integer = 0): Integer; overload;
    function setTimeout(handler: TTimerHandler; timeout: Integer; arguments: Variant): Integer; overload;
    procedure clearTimeout(handle: Integer = 0);
    function setInterval(handler: TTimerHandler; timeout: Integer = 0): Integer; overload;
    function setInterval(handler: TTimerHandler; timeout: Integer; arguments: Variant): Integer; overload;
    procedure clearInterval(handle: Integer = 0);
    function createImageBitmap(image: TCanvasImageSource): JImageBitmap; overload;
    function createImageBitmap(image: JImageData): JImageBitmap; overload;
    function createImageBitmap(image: TCanvasImageSource; options: JImageBitmapOptions): JImageBitmap; overload;
    function createImageBitmap(image: JImageData; options: JImageBitmapOptions): JImageBitmap; overload;
    function createImageBitmap(image: TCanvasImageSource; sx, sy, sw, sh: Integer): JImageBitmap; overload;
    function createImageBitmap(image: JImageData; sx, sy, sw, sh: Integer): JImageBitmap; overload;
    function createImageBitmap(image: TCanvasImageSource; sx, sy, sw, sh: Integer; options: JImageBitmapOptions): JImageBitmap; overload;
    function createImageBitmap(image: JImageData; sx, sy, sw, sh: Integer; options: JImageBitmapOptions): JImageBitmap; overload;
  end;

  JNavigator = class external 'Navigator'
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JNavigatorID = class external 'NavigatorID'
  public
    appCodeName: String;
    appName: String;
    appVersion: String;
    platform: String;
    product: String;
    productSub: String; { Exposed=Window }
    userAgent: String;
    vendor: String; { Exposed=Window }
    vendorSub: String; { Exposed=Window }
    oscpu: String; { Exposed=Window }
    function taintEnabled: Boolean; { Exposed=Window }
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JNavigatorLanguage = class external 'NavigatorLanguage'
  public
    language: String;
  end;

  // NoInterfaceObject
  JNavigatorContentUtils = class external 'NavigatorContentUtils'
  public
    procedure registerProtocolHandler(scheme: String; url: String; title: String);
    procedure registerContentHandler(mimeType: String; url: String; title: String);
    function isProtocolHandlerRegistered(scheme: String; url: String): String;
    function isContentHandlerRegistered(mimeType: String; url: String): String;
    procedure unregisterProtocolHandler(scheme: String; url: String);
    procedure unregisterContentHandler(mimeType: String; url: String);
  end;

  // NoInterfaceObject
  JNavigatorCookies = class external 'NavigatorCookies'
  public
    cookieEnabled: Boolean;
  end;

  JPluginArray = partial class external 'PluginArray'
  public
    length: Integer;
    procedure refresh(reload: Boolean = False);
  end;

  JMimeTypeArray = partial class external 'MimeTypeArray'
  public
    length: Integer;
  end;

  // NoInterfaceObject
  JNavigatorPlugins = class external 'NavigatorPlugins'
  public
    plugins: JPluginArray; { SameObject }
    mimeTypes: JMimeTypeArray; { SameObject }
    function javaEnabled: Boolean;
  end;

  JPlugin = partial class external 'Plugin'
  public
    name: String;
    description: String;
    filename: String;
    length: Integer;
  end;

  // LegacyUnenumerableNamedProperties
  JPluginArray = partial class external 'PluginArray'
  public
    function item(&index: Integer): JPlugin;
    function namedItem(&name: String): JPlugin;
  end;

  JMimeType = class external 'MimeType'
  public
    &type: String;
    description: String;
    suffixes: String;
    enabledPlugin: JPlugin;
  end;

  // LegacyUnenumerableNamedProperties
  JMimeTypeArray = partial class external 'MimeTypeArray'
  public
    function item(&index: Integer): JMimeType;
    function namedItem(&name: String): JMimeType;
  end;

  // LegacyUnenumerableNamedProperties
  JPlugin = partial class external 'Plugin'
  public
    function item(&index: Integer): JMimeType;
    function namedItem(&name: String): JMimeType;
  end;

  TMessageEventSource = Variant; // TODO

  // Exposed=( Window , Worker)
  JMessagePort = class external 'MessagePort' (JEventTarget)
  public
    onmessage: TEventHandler;
    procedure postMessage(message: Variant; transfer: Variant);
    procedure start;
    procedure close;
  end;

  JMessageEventInit = class external 'MessageEventInit' (JEventInit)
  public
    data: Variant;
    origin: String;
    lastEventId: String;
    source: TMessageEventSource;
    ports: array of JMessagePort;
  end;

  // Exposed = (Window, Worker)
  JMessageEvent = class external 'MessageEvent' (JEvent)
  public
    data: Variant;
    origin: String;
    lastEventId: String;
    source: TMessageEventSource;
    procedure initMessageEvent(&type: String; bubbles, cancelable: Boolean;
      data: Variant; origin: String; lastEventId: String;
      source: TMessageEventSource; ports: array of JMessagePort);
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JMessageEventInit); overload;
  end;

  JEventSourceInit = class external 'EventSourceInit'
  public
    withCredentials: Boolean;
  end;

  // Exposed = (Window, Worker)
  JEventSource = class external 'EventSource' (JEventTarget)
  const
    CONNECTING: Integer = 0;
    OPEN: Integer = 1;
    CLOSED: Integer = 2;
  public
    url: String;
    withCredentials: Boolean;
    readyState: Integer;
    onopen: TEventHandler;
    onmessage: TEventHandler;
    onerror: TEventHandler;
    constructor Create(url: String); overload;
    constructor Create(url: String; eventSourceInitDict: JEventSourceInit); overload;
    procedure close;
  end;

  JBinaryType = String;
  JBinaryTypeHelper = strict helper for JBinaryType
    const Blob = 'blob';
    const ArrayBuffer = 'arraybuffer';
  end;

  // Exposed = (Window, Worker)
  JWebSocket = partial class external 'WebSocket' (JEventTarget)
  const
    CONNECTING: Integer = 0;
    OPEN: Integer = 1;
    CLOSING: Integer = 2;
    CLOSED: Integer = 3;
  public
    url: String;
    readyState: Integer;
    bufferedAmount: Integer;
    onopen: TEventHandler;
    onerror: TEventHandler;
    onclose: TEventHandler;
    extensions: String;
    protocol: String;
    onmessage: TEventHandler;
    binaryType: JBinaryType;
    constructor Create(url: String); overload;
    constructor Create(url: String; protocol: String); overload;
    constructor Create(url: String; protocols: array of String); overload;
    procedure close; overload;
    procedure close(code: Integer { Clamp } ); overload;
    procedure close(code: Integer { Clamp } ; reason: String); overload;
    procedure send(data: String); overload;
    procedure send(data: JArrayBuffer); overload;
    procedure send(data: JArrayBufferView); overload;
  end;

  JCloseEventInit = class external 'CloseEventInit' (JEventInit)
  public
    wasClean: Boolean;
    code: Integer;
    reason: String;
  end;

  // Exposed = (Window, Worker)
  JCloseEvent = class external 'CloseEvent' (JEvent)
  public
    wasClean: Boolean;
    code: Integer;
    reason: String;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JCloseEventInit); overload;
  end;

  // Exposed = (Window, Worker)
  JMessageChannel = class external 'MessageChannel'
  public
    port1: JMessagePort;
    port2: JMessagePort;
    constructor Create;
  end;

  // Exposed = (Window, Worker)
  JBroadcastChannel = class external 'BroadcastChannel' (JEventTarget)
  public
    name: String;
    onmessage: TEventHandler;
    procedure postMessage(message: Variant);
    procedure close;
    constructor Create(name: String);
  end;

  // Exposed=Worker
  JWorkerLocation = class external 'WorkerLocation'
  public
    origin: String;
    protocol: String;
    host: String;
    hostname: String;
    port: String;
    pathname: String;
    search: String;
    hash: String;
  end;

  // Exposed=Worker
  JWorkerNavigator = partial class external 'WorkerNavigator'
  end;

  // Exposed=Worker
  JWorkerGlobalScope = class external 'WorkerGlobalScope' (JEventTarget)
  public
    self: JWorkerGlobalScope;
    location: JWorkerLocation;
    navigator: JWorkerNavigator;
    onerror: TOnErrorEventHandler;
    onlanguagechange: TEventHandler;
    onoffline: TEventHandler;
    ononline: TEventHandler;
    onrejectionhandled: TEventHandler;
    onunhandledrejection: TEventHandler;
    procedure importScripts(urls: String);
  end;

  // Global=( Worker , DedicatedWorker),Exposed=DedicatedWorker
  JDedicatedWorkerGlobalScope = class external 'DedicatedWorkerGlobalScope' (JWorkerGlobalScope)
  public
    onmessage: TEventHandler;
    procedure postMessage(message: Variant; transfer: Variant); // TODO
    procedure close;
  end;

  // Global=( Worker , SharedWorker),Exposed=SharedWorker
  JSharedWorkerGlobalScope = class external 'SharedWorkerGlobalScope' (JWorkerGlobalScope)
  public
    name: String;
    applicationCache: JApplicationCache;
    onconnect: TEventHandler;
    procedure close;
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JAbstractWorker = class external 'AbstractWorker'
  public
    onerror: TEventHandler;
  end;

  JWorkerType = String;
  JWorkerTypeHelper = strict helper for JWorkerType
    const Classic = 'classic';
    const Module = 'module';
  end;

  JWorkerOptions = class external 'WorkerOptions'
  public
    &type: JWorkerType;
// TODO    credentials: JRequestCredentials;
  end;

  // Exposed = (Window, Worker)
  JWorker = class external 'Worker' (JEventTarget)
  public
    onmessage: TEventHandler;
    procedure terminate;
    procedure postMessage(message: Variant; transfer: Variant); // TODO
    constructor Create(scriptURL: String); overload;
    constructor Create(scriptURL: String; options: JWorkerOptions); overload;
  end;

  // Exposed = (Window, Worker)
  JSharedWorker = class external 'SharedWorker' (JEventTarget)
  public
    port: JMessagePort;
    constructor Create(scriptURL: String); overload;
    constructor Create(scriptURL, name: String); overload;
    constructor Create(scriptURL, name: String; options: JWorkerOptions); overload;
  end;

  // NoInterfaceObject, Exposed = (Window, Worker)
  JNavigatorConcurrentHardware = class external 'NavigatorConcurrentHardware'
  public
    hardwareConcurrency: Integer;
  end;

  JStorage = class external 'Storage'
  public
    length: Integer;
    function key(&index: Integer): String;
    function getItem(key: String): String;
    procedure setItem(key: String; value: String);
    procedure removeItem(key: String);
    procedure clear;
  end;

  // NoInterfaceObject
  JWindowSessionStorage = class external 'WindowSessionStorage'
  public
    sessionStorage: JStorage;
  end;

  // NoInterfaceObject
  JWindowLocalStorage = class external 'WindowLocalStorage'
  public
    localStorage: JStorage;
  end;

  JStorageEventInit = class external 'StorageEventInit' (JEventInit)
  public
    key: String;
    oldValue: String;
    newValue: String;
    url: String;
    storageArea: JStorage;
  end;

  JStorageEvent = class external 'StorageEvent' (JEvent)
  public
    key: String;
    oldValue: String;
    newValue: String;
    url: String;
    storageArea: JStorage;
    constructor Create(&type: String); overload;
    constructor Create(&type: String; eventInitDict: JStorageEventInit); overload;
  end;

  JHTMLAppletElement = class external 'HTMLAppletElement' (JHTMLElement)
  public
    align: String; { CEReactions }
    alt: String; { CEReactions }
    archive: String; { CEReactions }
    code: String; { CEReactions }
    codeBase: String; { CEReactions }
    height: String; { CEReactions }
    hspace: Integer; { CEReactions }
    name: String; { CEReactions }
    _object: String; { CEReactions }
    vspace: Integer; { CEReactions }
    width: String; { CEReactions }
  end;

  JHTMLMarqueeElement = class external 'HTMLMarqueeElement' (JHTMLElement)
  public
    behavior: String; { CEReactions }
    bgColor: String; { CEReactions }
    direction: String; { CEReactions }
    height: String; { CEReactions }
    hspace: Integer; { CEReactions }
    loop: Integer; { CEReactions }
    scrollAmount: Integer; { CEReactions }
    scrollDelay: Integer; { CEReactions }
    trueSpeed: Boolean; { CEReactions }
    vspace: Integer; { CEReactions }
    width: String; { CEReactions }
    onbounce: TEventHandler;
    onfinish: TEventHandler;
    onstart: TEventHandler;
    procedure start;
    procedure stop;
  end;

  JHTMLFrameSetElement = class external 'HTMLFrameSetElement' (JHTMLElement)
  public
    cols: String; { CEReactions }
    rows: String; { CEReactions }
  end;

  JHTMLFrameElement = class external 'HTMLFrameElement' (JHTMLElement)
  public
    name: String; { CEReactions }
    scrolling: String; { CEReactions }
    src: String; { CEReactions }
    frameBorder: String; { CEReactions }
    longDesc: String; { CEReactions }
    noResize: Boolean; { CEReactions }
    contentDocument: JDocument;
    contentWindow: JWindowProxy;
    marginHeight: String; { CEReactions,TreatNullAs=EmptyString }
    marginWidth: String; { CEReactions,TreatNullAs=EmptyString }
  end;

  // HTMLConstructor
  JHTMLDirectoryElement = class external 'HTMLDirectoryElement' (JHTMLElement)
  public
    compact: Boolean; { CEReactions }
  end;

  // HTMLConstructor
  JHTMLFontElement = class external 'HTMLFontElement' (JHTMLElement)
  public
    color: String; { CEReactions,TreatNullAs=EmptyString }
    face: String; { CEReactions }
    size: String; { CEReactions }
  end;

  // NoInterfaceObject
  JExternal = class external 'External'
  public
    procedure AddSearchProvider;
    procedure IsSearchProviderInstalled;
  end;

  // OverrideBuiltins
  JDocument = partial class external 'Document'
  public
    location: JLocation; { PutForwards=href,Unforgeable }
    domain: String;
    referrer: String;
    cookie: String;
    lastModified: String;
    readyState: JDocumentReadyState;
    title: String; { CEReactions }
    dir: String; { CEReactions }
    body: JHTMLElement; { CEReactions }
    head: JHTMLHeadElement;
    images: JHTMLCollection; { SameObject }
    embeds: JHTMLCollection; { SameObject }
    plugins: JHTMLCollection; { SameObject }
    links: JHTMLCollection; { SameObject }
    forms: JHTMLCollection; { SameObject }
    scripts: JHTMLCollection; { SameObject }
    currentScript: THTMLOrSVGScriptElement;
    defaultView: JWindowProxy;
    activeElement: JElement;
    designMode: String; { CEReactions }
    onreadystatechange: TEventHandler; { LenientThis }
    fgColor: String; { CEReactions,TreatNullAs=EmptyString }
    linkColor: String; { CEReactions,TreatNullAs=EmptyString }
    vlinkColor: String; { CEReactions,TreatNullAs=EmptyString }
    alinkColor: String; { CEReactions,TreatNullAs=EmptyString }
    bgColor: String; { CEReactions,TreatNullAs=EmptyString }
    anchors: JHTMLCollection; { SameObject }
    applets: JHTMLCollection; { SameObject }
    all: JHTMLAllCollection; { SameObject }
// TODO    function (&name: String): Variant;
    function getElementsByName(elementName: String): JNodeList;
// TODO    function open(&type: String = 'text/html'; replace: String = ): JDocument; { CEReactions }
    function open(url: String; &name: String; features: String): JWindowProxy;
    procedure close; { CEReactions }
    procedure write(text: String); { CEReactions }
    procedure writeln(text: String); { CEReactions }
    function hasFocus: Boolean;
    function execCommand(commandId: String; showUI: Boolean = False): Boolean; overload; { CEReactions }
    function execCommand(commandId: String; showUI: Boolean; value: String): Boolean; overload; { CEReactions }
    function queryCommandEnabled(commandId: String): Boolean;
    function queryCommandIndeterm(commandId: String): Boolean;
    function queryCommandState(commandId: String): Boolean;
    function queryCommandSupported(commandId: String): Boolean;
    function queryCommandValue(commandId: String): String;
    procedure clear;
    procedure captureEvents;
    procedure releaseEvents;
  end;

(*
  // PrimaryGlobal,LegacyUnenumerableNamedProperties
  JWindow = partial class external 'Window' (JEventTarget)
  public
    window: JWindowProxy; { Unforgeable }
    self: JWindowProxy; { Replaceable }
    document: JDocument; { Unforgeable }
    name: String;
    location: JLocation; { PutForwards=href,Unforgeable }
    history: JHistory;
    customElements: JCustomElementRegistry;
    locationbar: JBarProp; { Replaceable }
    menubar: JBarProp; { Replaceable }
    personalbar: JBarProp; { Replaceable }
    scrollbars: JBarProp; { Replaceable }
    statusbar: JBarProp; { Replaceable }
    toolbar: JBarProp; { Replaceable }
    status: String;
    closed: Boolean;
    frames: JWindowProxy; { Replaceable }
    length: Integer; { Replaceable }
    top: JWindowProxy; { Unforgeable }
    opener: Variant;
    parent: JWindowProxy; { Replaceable }
    frameElement: JElement;
    navigator: JNavigator;
    applicationCache: JApplicationCache;
    external: JExternal; { Replaceable,SameObject }
    procedure close;
    procedure stop;
    procedure focus;
    procedure blur;
    function open(url: String = about:blank; target: String = _blank; features: String =  { TreatNullAs=EmptyString } ): JWindowProxy;
    function (&name: String): Variant;
    procedure alert;
    procedure alert(message: String);
    function confirm(message: String = ): Boolean;
    function prompt(message: String = ; &default: String = ): String;
    procedure print;
    function requestAnimationFrame(Callback: JFrameRequestCallback): Integer;
    procedure cancelAnimationFrame(handle: Integer);
    procedure postMessage(message: Variant; targetOrigin: String; transfer: array of Variant = );
    procedure captureEvents;
    procedure releaseEvents;
  end;
*)
