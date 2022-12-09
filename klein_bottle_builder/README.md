# About

Although container images are excellent tools for ensuring consistently and reproducibly creating environments, 
there is a strong irony in that it's extremely difficult to consistently and reproducibly create the images in the first place.

The goal of the Klein Bottle builder project is to achieve the highest possible standards of consistency and reproducibility
in regards to creating container images.

# High Level Goals

## Rebuildable

The image itself contains all artifacts necessary to building the image.
When built, all layers will be perfectly recreated with the same hashes.

### Nouns
`Image`
```typescript
{
    artifacts: { 
        main: Artifact,
        [id: str]: Artifact
    }
    spec: BuildSpec
    layers: Layer[]
}
```

`Layer`
```typescript
{
    sha: str
}
```

`BuildSpec`
```typescript
{
    id: ImageId
    version: SemVar
    artifacts: { 
        main: ArtifactSpec,
        [id: str]: ArtifactSpec
    }
}
```

`Artifact`
```typescript
{
    content: byte[]
}
```

### Verbs
```typescript
build(spec : BuildSpec): Image
```

### Testing
1. Build the image
```typescript
image_1 = build(**spec)
```
2. Build the image, using the artifacts from the image
```typescript
image_2 = build(**image_1.spec, artifacts = image_1.artifacts)
```
3. Compare the produced layers and verify they are identical
```python
assert image_1.artifacts == image_2.artifacts
assert image_1.layers == image_2.layers
```

## Traceable

The image contains artifacts that came from a 3rd party source.
Each artifact clearly indicates where it came from.

### Nouns

`ArtifactWithSource`
```typescript
{
    source: ArtifactSource
} & Artifact
```

`ArtifactSource`
```typescript
```

### Testing
> All potential build artifacts are checked to ensure they have appropriate meta-data attached that claims their source

## Regeneratable

As traceable, but said source can be used to perfectly recreate the associated artifact.

#### To test:

> [artifact.source.dependencies] are 
> [artifact.source] is `local`, `Perfectly Regeneratable` or `Reputably Immutable Regeneratable`
> [artifact] === [image.artifact] The generated artifact is exactly equal to the artifact in source.


### Perfectly regeneratable

If the source is generated from purely local artifacts, it is perfectly regeneratable.

### Reputably immutable regeneratable

If the source for one or more artifacts is from a reputably reproducible external source, it is considered reputably immutable regeneratable.

Note that both reputation and immutability are required for aspect.

Examples include:
- Fetching from external version control
    - Do:
        - use a specific hash [Reputable and immutable]
        - use a specific version [Reputable and generally immutable]
    - Do *not*:
        - use a branch or rolling release identifier [Reputable but non-immutable]
- Fetching from a package manager
    - Do *not*:
        - Use a package that downloads additional dependencies [non-immutable]
    - Do:
        - Use a specific version and build [Reputable and immutable]

#### To test:

> [artifact.source] is from reputable vendor.
> [artifact.source] is considered immutable target for said vendor.
> [artifact] === [image.artifact] The generated artifact is exactly equal to the artifact in source.

## Verifiable

As Regeneratable, but said source can be used to verify if the stored artifact matches the source.

### Reference only

Most external sources fall under this category. Most often we cannot guarantee a sources' immutability.


