(ert-deftest commit-lookup ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id))
           (commit-short (libgit-commit-lookup-prefix repo (substring id 0 7))))
      (should (libgit-commit-p commit))
      (should (string= id (libgit-commit-id commit)))
      (should (string= id (libgit-commit-id commit-short)))
      (should-error (libgit-commit-lookup repo "test") :type 'giterr))))

(ert-deftest commit-parentcount ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (= 0 (libgit-commit-parentcount commit))))
    (commit-change "test" "more content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (= 1 (libgit-commit-parentcount commit))))))

(ert-deftest commit-parent-id ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (parent-id (libgit-reference-name-to-id repo "HEAD")))
      (commit-change "test" "more content")
      (let* ((this-id (libgit-reference-name-to-id repo "HEAD"))
             (commit (libgit-commit-lookup repo this-id)))
        (should (string= parent-id (libgit-commit-parent-id commit)))
        (should (string= parent-id (libgit-commit-parent-id commit 0)))
        (should (string= parent-id (libgit-commit-id (libgit-commit-parent commit))))
        (should (string= parent-id (libgit-commit-id (libgit-commit-parent commit 0))))
        (should-error (libgit-commit-parent-id commit 1) :type 'args-out-of-range)
        (should-error (libgit-commit-parent commit 1) :type 'giterr)))))

(ert-deftest commit-ancestor ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id-1 (libgit-reference-name-to-id repo "HEAD")))
      (commit-change "test" "more content")
      (let* ((id-2 (libgit-reference-name-to-id repo "HEAD")))
        (commit-change "test" "so much content wow")
        (let* ((id-3 (libgit-reference-name-to-id repo "HEAD"))
               (commit (libgit-commit-lookup repo id-3)))
          (should (string= id-3 (libgit-commit-id (libgit-commit-nth-gen-ancestor commit 0))))
          (should (string= id-2 (libgit-commit-id (libgit-commit-nth-gen-ancestor commit 1))))
          (should (string= id-1 (libgit-commit-id (libgit-commit-nth-gen-ancestor commit 2))))
          (should-error (libgit-commit-nth-gen-ancestor commit 3) :type 'giterr)
          (should-error (libgit-commit-nth-gen-ancestor commit -1) :type 'giterr))))))

(ert-deftest commit-author-committer ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id))
           (author (libgit-commit-author commit))
           (committer (libgit-commit-committer commit)))
      (should (string= "A U Thor" (libgit-signature-name author)))
      (should (string= "author@example.com" (libgit-signature-email author)))
      (should (string= "A U Thor" (libgit-signature-name committer)))
      (should (string= "author@example.com" (libgit-signature-email committer))))))

(ert-deftest commit-message ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content" "here is a message!")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (string= "here is a message!\n" (libgit-commit-message commit))))))

(ert-deftest commit-summary ()
  (with-temp-dir path
    (init)
    (commit-change "test" "content" "here is a message!\n\nhere is some more info")
    (let* ((repo (libgit-repository-open path))
           (id (libgit-reference-name-to-id repo "HEAD"))
           (commit (libgit-commit-lookup repo id)))
      (should (string= "here is a message!" (libgit-commit-summary commit))))))
