## Submitting a Pull Request
1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Add specs for your unimplemented feature or bug fix.
4. Run `bundle exec rake spec`. If your specs pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `bundle exec rake`. If your specs fail, return to step 5.
7. Run `open coverage/index.html`. If your changes are not completely covered
   by your tests, return to step 3.
8. Run `RUBYOPT=W2 bundle exec rake spec 2>&1 | grep oauth2`. If your changes
   produce any warnings, return to step 5.
9. Add documentation for your feature or bug fix.
10. Run `bundle exec rake verify_measurements`. If your changes are not 100%
    documented, go back to step 9.
11. Commit and push your changes.
12. [Submit a pull request.][pr]

[fork]: http://help.github.com/fork-a-repo/
[branch]: http://learn.github.com/p/branching.html
[pr]: http://help.github.com/send-pull-requests/
