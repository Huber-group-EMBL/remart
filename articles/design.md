# design

## Function names, signatures, and return values

The function names, arguments, and return values come from the biomaRt
package, as this package is aiming to be a drop-in replacement for
biomaRt.

Some arguments are no longer required, and are subsumed into the
ellipsis (`...`) argument. For example, the `mart` argument is no longer
required, as the connection to the database is handled internally by the
package.

## FAQ

### Why a new package?

Two main reasons:

- Both packages can co-exist for a while, so we can start the migration
  even if all use cases are not yet supported by remart.
- While Ensembl is moving away from BioMart for newer releases:
  - Older releases remain available, and are still accessible via
    BioMart.
  - BioMart is an open-source project that is also used by other
    databases. remart is only providing access to Ensembl.

There is thus value in keeping the biomaRt package alive to address more
complex edge cases, and external Mart databases, while remart can
provide a drop-in replacement for newer Ensembl releases.
