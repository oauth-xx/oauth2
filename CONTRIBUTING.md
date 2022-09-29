## Contributing

Bug reports and pull requests are welcome on GitLab at [https://gitlab.com/oauth-xx/oauth2][🚎src-main]
. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct][conduct].

To submit a patch, please fork the project and create a patch with
tests. Once you're happy with it send a pull request and post a message to the
[google group][mailinglist] or on the [gitter chat][🏘chat].

## Detailed instructions on Submitting a Pull Request
1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Add specs for your unimplemented feature or bug fix.
4. Run `bundle exec rake spec`. If your specs pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `bundle exec rake`. If your specs fail, return to step 5.
7. Run `open coverage/index.html`. If your changes are not completely covered
   by your tests, return to step 3.
8. Add documentation for your feature or bug fix.
9. Run `bundle exec rake verify_measurements`. If your changes are not 100%
   documented, go back to step 8.
10. Commit and push your changes.
11. [Submit a pull request.][pr]

[fork]: http://help.github.com/fork-a-repo/
[branch]: http://learn.github.com/p/branching.html
[pr]: http://help.github.com/send-pull-requests/

## Contributors

See: [https://gitlab.com/oauth-xx/oauth2/-/graphs/main][🚎contributors]

Made with [contributors-img][contrib-rocks].

[comment]: <> (Following links are used by README, CONTRIBUTING, Homepage)
[conduct]: https://gitlab.com/oauth-xx/oauth2/-/blob/main/CODE_OF_CONDUCT.md
[🚎contributors]: https://gitlab.com/oauth-xx/oauth2/-/graphs/main
[mailinglist]: http://groups.google.com/group/oauth-ruby
[🚎src-main]: https://gitlab.com/oauth-xx/oauth2/-/tree/main
[🏘chat]: https://gitter.im/oauth-xx/oauth2