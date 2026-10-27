# Contributing

## Applicability and precedence

Organization-default contribution process for all OSS and FOSS projects, as defined in [On Openness][openness] in the organization profile. Repository READMEs may add toolchain, build, test, and style requirements.

## Code of Conduct

Participation is governed by the applicable code of conduct ([CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) and any repository-specific code); contributing constitutes agreement to uphold it.

## Channels

Public repositories reserve issues and pull requests for maintainers' internal use; neither is open to outside contributors. Inbound contributions arrive through Discussions and forks. Route by nature of matter:

- Suspected security vulnerability: use its private vulnerability reporting; never [Discussions][discussions] or email.
- Public-record matters: organization [Discussions][discussions-new]. Default channel: search first; one topic per matter; reproducible.
- Private matters: contact[at]rebis[dot]cn. State the affected repository and a minimal, non-sensitive summary; further details only on request.
- Accounts: this organization is present on GitHub, [Codeberg][codeberg], and [CNB][cnb]. A contributor needs an account only on the forge where they fork; the code-offering discussion takes place on that fork, and a maintainer performs the integration on GitHub, so contributing never requires a GitHub account.

Disclosure that would harm any party, compromise security, or concern identifiable individuals, rights, or obligations goes private; anything requiring open technical review and a durable public record goes to [Discussions][discussions]. When in doubt, use the private channel.

## Issues and pull requests

There is no issue or pull-request path against a public repository:

- What would be an issue: open a discussion.
- What would be a pull request: open it against your own fork, never against the upstream repository. A maintainer fetches your branch from there.

Entry point: [Discussions][discussions].

### Filing a matter as a discussion

Search existing discussions first. Title: `[<repo>] <short problem or proposal>`. Include, as applicable: repository, version or commit SHA, platform, and toolchain; expected versus actual behaviour; reproduction steps, with a [minimal reproducible example][MRE] where possible; scope, impact, logs, and any candidate fix or API sketch. Await triage; direction is confirmed in-thread. Trivial fixes may proceed without a prior proposal at a maintainer's discretion. Security and private matters use the channels above, never a discussion.

### Offering code from a fork

1. Fork; branch from the updated default branch; record the upstream base commit SHA. One change per branch.
2. Build and test clean per the repository README. Follow [Conventional Commits][conventional]; match the surrounding style, including doc comments on public API. Prefer additive, non-breaking changes; flag breaking ones explicitly.
3. Push, then file (or reuse) a matter in [Discussions][discussions] titled `[<repo>] Proposal: <short change summary>` stating: upstream repository and base commit SHA; fork URL and branch; what the change does and why, linking any related matter; test evidence and, for behaviour changes, before/after notes.
4. Open a pull request on your own fork, from the offered branch into your fork's default branch. Review happens in that pull request's discussion, on whichever forge you hold the account. On acceptance a maintainer fetches from your fork and integrates by squash, rebase, or cherry-pick. No pull request against an upstream repository is opened at any point.
5. Keep the fork branch stable and available, without force-pushes, until a decision is announced in the pull request. Acceptance is not guaranteed.
6. On acceptance the record is preserved upstream, so that it outlives the fork: the maintainer mirrors the pull request's discussion into a public issue in the upstream repository, and carries the trailers forward into the integrated commit.

### If the shape of it is unfamiliar

Nothing here is idiosyncratic. Both arrangements above are older than this organization, and projects that have used them for decades write them down.

- Ghostty keeps its issue tracker to actionable items and routes discussion and feature requests to Discussions instead, so that every entry left in the tracker is ready to be worked on. The argument is worth reading: [Issues are actionable][ghostty-issues].
- The projects that have always worked this way show what the shape looks like in practice: Linux in [Submitting patches][linux-patches]; Git in [Submitting Patches][git-patches] and [Git workflows][git-workflows]. The common ground is that no code contribution arrives as a pull request against the upstream repository and a maintainer applies it by hand. The difference is that they receive it on a Git mailing list; here it is a fork branch and a pull request on that fork.

Read them for the shape of the process and the reasoning behind it. Their commit formats, patch disciplines, and review habits, including how a series is iterated, are not this organization's: where the two differ, this document governs.

## Licensing

By contributing you license your contribution under the affected repository's project licence (inbound = outbound), per its LICENSE or COPYING (see NOTICE where present), and warrant that you have the right to license it so.

A signed CLA must additionally be on file before any code offering is integrated. One signature covers all contributions under this guide for the current CLA version; re-execution is required only upon a version change.

### Completing and filing the CLA

The canonical instrument is the fillable PDF (`CLA/ICLA.pdf`, or `CLA/CCLA.pdf` for employer-side execution). The version hash displayed top-right identifies the version signed and is bound by the signature.

1. Obtain the current PDF: latest published `ICLA.pdf` for personal capacity; for employer-behalf contributions, commence the CCLA via contact[at]rebis[dot]cn first.
2. Fill every field in an AcroForm-capable viewer: full name; personal email under your long-term control (employer-owned addresses excluded); platform IDs; GPG or SSH key fingerprint; date; signature. All field content must be printable US-ASCII (ISO/IEC 646 IRV); the characters `\ % & # ^ _ ~ $` and braces are reserved and rejected by `filed.lua` with the offending byte position. Romanize names as applicable (the filed record is typeset in Latin Modern and cannot represent CJK), and keep each field to a single line. An unsigned footer showing the digest is expected.
3. Sign the nonce, not the PDF. On request the office publishes a nonce of exactly `cla.rebis.cn:<version-hash>:<32-random-hex>`; return a detached signature over precisely those bytes (`ssh-keygen -Y sign -f <private-key> -n cla.rebis.cn nonce.txt` or `gpg --detach-sign --armor -u <keyid> nonce.txt`) and place it, or a signed commit ref, in the Signature field. The office verifies it against the fingerprint on file.
4. File via the private channel (contact[at]rebis[dot]cn); CLA filings are legal matters, never filed in [Discussions][discussions].
5. The office completes the filing: it recomputes the agreement digest as SHA-256 over the exact UTF-8 bytes of `version-hash ‖ email ‖ platform-ID ‖ date`; mints the check code as the first 64 bits of HMAC-SHA-256 under the office key, encoded in Crockford Base32 and hyphenated 5-5-3; and returns the filed copy, whose footer carries the digest, the check code, and its Code 39 barcode. The filed copy constitutes the evidence of record; receipt is confirmed in the code-offering discussion or by email reply.
6. Verification: anyone can recompute the digest from the four filed values; the check code is minted solely under the office key and verified by the office at each integration.

[openness]: profile/README.md#关于开放--on-openness
[discussions]: https://github.com/orgs/rebis-org/discussions
[discussions-new]: https://github.com/orgs/rebis-org/discussions/new/choose
[conventional]: https://www.conventionalcommits.org/en/v1.0.0/
[MRE]: https://stackoverflow.com/help/minimal-reproducible-example
[ghostty-issues]: https://github.com/ghostty-org/ghostty/blob/main/CONTRIBUTING.md#issues-are-actionable
[linux-patches]: https://docs.kernel.org/process/submitting-patches.html
[git-patches]: https://git-scm.com/docs/SubmittingPatches
[git-workflows]: https://git-scm.com/docs/gitworkflows
[codeberg]: https://codeberg.org/rebis-org
[cnb]: https://cnb.cool/rebis-org
