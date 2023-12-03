## Quarto blog

My personal blog on 
[sinanpl.github.io](https://sinanpl.github.io)
built with [Quarto](https://quarto.org/)

Notes for self & others interested in starting a blog with quarto.

---

### Set-up

This repo is set up to work with github actions and will prepare
an R & python environment as specified in requirements. 

The reason to prefer this approach to `quarto publish` with Github Pages
is that `quarto publish` will automatically render all (draft) content
and push it to gh-pages branch, including unchecked files. For this reason
Github actions I found github actions more interesting, nevertheless, this 
comes with challenges.

--- 

### Workflow

- Optional: branch for draft from main
- Add a post folder with index.qmd in posts/
- Render a local preview with `quarto preview`
- Publish:
    - `quarto publish gh-pages`
        - does not depend on commit/push on main
    - github actions
        - triggered by commit & push on main, published to gh-pages branch
