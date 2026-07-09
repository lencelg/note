#import "@preview/scholia:0.1.0": *

// options: theme: "light" | "dark" · prose: "notes" | "book" · fonts: (…)
#show: scholia

#cover("title here", subtitle: "lencelg", author: "lencelg from Arcadia Bay", date: "2026 summer")

#set text(font: "Source Han Sans")
#show raw: set text(font: "Hack Nerd Font")
#outline()

#pagebreak()

#let code(body) = text(fill: blue, body)
