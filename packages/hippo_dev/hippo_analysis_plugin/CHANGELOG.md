## 0.1.1

- Preserve explicit constructor calls through public typedefs of private classes
  from another library, where dot shorthand cannot access the underlying class.
- Keep supporting aliases to public classes and private classes in the same library.

## 0.1.0

- Add the `prefer_dot_shorthands` lint for contextually typed enum values,
  static members, and nongeneric constructors, with an IDE quick fix.
- Preserve explicit generic arguments, inference-dependent expressions, const
  semantics, import prefixes, and comments.
