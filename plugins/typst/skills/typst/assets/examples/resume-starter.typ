// resume-starter.typ — paste-runnable modern-cv resume.
//
// Uses font overrides to "New Computer Modern" (bundled with Typst) so it
// compiles on a fresh macOS without installing Roboto / Source Sans Pro /
// FontAwesome. For the canonical Awesome-CV look, install those fonts and
// remove the `font:` / `header-font:` overrides at the bottom of the
// resume.with(...) call.
//
// Compile:  typst compile resume-starter.typ
// Preview:  typst compile resume-starter.typ /tmp/preview.png --pages 1

#import "@preview/modern-cv:0.10.0": *

#show: resume.with(
  author: (
    firstname: "Jane",
    lastname: "Doe",
    email: "jane@example.com",
    phone: "(+1) 555-0100",
    github: "janedoe",
    linkedin: "janedoe",
    address: "San Francisco, CA",
    positions: (
      "Senior Software Engineer",
    ),
  ),
  profile-picture: none,
  date: datetime.today().display(),
  paper-size: "us-letter",
  accent-color: rgb("#26428b"),
  // Font overrides — remove these two lines if Roboto + Source Sans Pro are installed.
  font: "New Computer Modern",
  header-font: "New Computer Modern",
)

= Experience

#resume-entry(
  title: "Senior Engineer",
  location: "Acme Corp — Remote",
  date: "Jun 2019 - Present",
  description: "Platform team",
)

#resume-item[
  - Cut p99 latency 47% by moving reads to edge KV
  - Mentored 4 engineers across two timezones
  - Shipped weekly for 11 months with zero rollbacks
]

#resume-entry(
  title: "Software Engineer",
  location: "Startup Inc. — Remote",
  date: "Jun 2017 - Jun 2019",
  description: "Founding engineer",
)

#resume-item[
  - Designed and shipped real-time collaboration backend (WebSocket + CRDT)
  - Built CI from scratch; deploy pipeline shipped 200+ releases
]

= Education

#resume-entry(
  title: "Example University",
  location: "B.S. Computer Science",
  date: "Aug 2013 - May 2017",
  description: "GPA 3.8 / 4.0",
)

#resume-item[
  - Senior thesis: lock-free queue benchmarking under contention
  - Coursework: Distributed Systems, Compilers, Cryptography
]

= Skills

#resume-item[
  - *Languages:* Rust, Go, TypeScript, Python, SQL
  - *Infrastructure:* Cloudflare Workers, AWS, Kubernetes, Postgres, Redis
  - *Tools:* Git, Linux, Docker, Terraform
]
