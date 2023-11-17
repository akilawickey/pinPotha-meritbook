package org.leafylanka.pinpotha.models;

import java.io.Serializable;
import java.util.HashMap;

/**
 * Created by ZarSaeed on 6/22/2018.
 */

public class Post implements Serializable {
    private String photoUrl,note,postId;
    private HashMap<String,Object> timeStamp;
    public Post() {}

    //getters

    public String getPhotoUrl() {
        return photoUrl;
    }

    public String getNote() {
        return note;
    }

    public String getPostId() {
        return postId;
    }

    public HashMap<String, Object> getTimeStamp() {
        return timeStamp;
    }

    //setters

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public void setPostId(String postId) {
        this.postId = postId;
    }

    public void setTimeStamp(HashMap<String, Object> timeStamp) {
        this.timeStamp = timeStamp;
    }
}
