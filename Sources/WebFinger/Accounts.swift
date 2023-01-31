// Copyright © 2022 Alex Kovács. All rights reserved.

struct Account {
    static let lookup = [
        "alice@wonderland.com": """
            {
                "subject": "acct:alice@mastodon.social",
                "aliases": [
                    "https://mastodon.social/@alice",
                    "https://mastodon.social/users/alice"
                ],
                "links": [
                    {
                        "rel": "http://webfinger.net/rel/profile-page",
                        "type": "text/html",
                        "href": "https://mastodon.social/@alice"
                    },
                    {
                        "rel": "self",
                        "type": "application/activity+json",
                        "href": "https://mastodon.social/users/alice"
                    },
                    {
                        "rel": "http://ostatus.org/schema/1.0/subscribe",
                        "template": "https://mastodon.social/authorize_interaction?uri={uri}"
                    }
                ]
            }
            
            """
    ]
}
